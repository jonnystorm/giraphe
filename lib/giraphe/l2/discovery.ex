# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Discovery do
  @moduledoc """
  Discovery functions for switches.
  """

  alias Giraphe.Utility

  require Logger

  defp find_switches_with_non_empty_fdbs(switches) do
    Stream.filter switches, fn %{fdb: [{_, _, _} | _]} -> true; _ -> false end
  end

  defp fetch_switches(targets, gateway_mac) do
    :ok = Logger.debug "Fetching switches..."

    targets
      |> Stream.map(fn {target, physaddr} ->
        Giraphe.IO.get_switch target, physaddr, gateway_mac
      end)
      |> find_switches_with_non_empty_fdbs
      |> Enum.sort_by(&(&1.polladdr))
  end

  defp get_subnet_by_gateway_address(gateway_address) do
    gateway_address
      |> Giraphe.IO.get_target_routes
      |> Enum.filter(fn {_, next_hop} -> Utility.next_hop_is_self next_hop end)
      |> Utility.get_destinations_from_routes
      |> Enum.filter(&(&1 != gateway_address))
      |> Enum.filter(&Utility.is_not_default_address/1)
      |> Enum.sort
      |> Enum.reverse
      |> Utility.find_prefix_containing_address(gateway_address)
  end

  defp retrieve_arp_entries(subnet, gateway_address) do
    Utility.status "Retrieving ARP entries for '#{subnet}'..."

    gateway_address
      |> Giraphe.IO.get_target_arp_cache
      |> Enum.filter(fn {netaddr, _} -> NetAddr.contains?(subnet, netaddr) end)
  end

  @doc """
  Discover switches in subnet `subnet` by polling `gateway_address` ARP entries.

  Ping scans the corresponding subnet to induce ARP entries, then polls each IP
  for forwarding information.
  """
  @spec discover(NetAddr.t, NetAddr.t | nil) :: [Giraphe.Switch.t]

  def discover(gateway_address, nil) do
    if subnet = get_subnet_by_gateway_address gateway_address do
      Utility.status "Found subnet '#{subnet}' for gateway '#{gateway_address}'."

      discover gateway_address, subnet

    else
      :ok = Logger.error "Unable to find subnet for gateway '#{gateway_address}'."

      exit {:shutdown, 1}
    end
  end
  def discover(gateway_address, subnet) do
    Utility.status "Inducing ARP entries on '#{subnet}'..."
    :ok = Giraphe.IO.ping_subnet subnet

    arp_entries = retrieve_arp_entries subnet, gateway_address

    hosts = Enum.map_join arp_entries, ", ", &NetAddr.address(elem(&1, 0))

    Utility.status "Found the following hosts: #{hosts}."

    ip_to_mac = Enum.into arp_entries, %{}

    fetch_switches arp_entries, ip_to_mac[gateway_address]
  end
end

defimpl String.Chars, for: Tuple do
  import Kernel, except: [to_string: 1]

  def to_string(tuple) do
    string =
      tuple
        |> Tuple.to_list
        |> Enum.map(&String.Chars.to_string/1)
        |> Enum.join(", ")

    "{#{string}}"
  end
end
