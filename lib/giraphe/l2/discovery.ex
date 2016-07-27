# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Discovery do
  @moduledoc """
  Discovery functions for switches.
  """

  alias Giraphe.Utility

  defp find_switches_with_non_nil_fdbs(switches) do
    Stream.filter switches, fn %{fdb: nil} -> false; _ -> true end
  end

  defp get_switchport_by_mac(switch, mac) do
    Enum.find_value switch.fdb, fn {p, ^mac} -> p; _ -> nil end
  end

  def fetch_switches(targets, gateway_mac) do
    targets
      |> Enum.map(&Giraphe.IO.get_switch/1)
      |> find_switches_with_non_nil_fdbs
      |> Enum.map(fn s ->
        uplink = get_switchport_by_mac s, gateway_mac

        %{s | uplink: uplink}
      end)
  end

  defp get_subnet_by_gateway_address(gateway_address_string) do
    gateway_address = NetAddr.ip gateway_address_string

    gateway_address
      |> Giraphe.IO.get_target_routes
      |> Enum.filter(fn {_, next_hop} -> Utility.next_hop_is_self next_hop end)
      |> Utility.get_destinations_from_routes
      |> Enum.sort
      |> Enum.reverse
      |> Utility.find_prefix_containing_address(gateway_address)
  end

  @doc """
  Discover switches with a default gateway of `gateway_address`.

  Ping scans the corresponding subnet to induce ARP entries, then polls each IP
  for forwarding information.
  """
  @spec discover(String.t) :: [Giraphe.Switch.t]

  def discover(gateway_address) when is_binary gateway_address do
    subnet = get_subnet_by_gateway_address gateway_address

    discover "#{subnet}", gateway_address
  end

  @doc """
  Discover switches in subnet `subnet` by polling `gateway_address` ARP entries.

  Ping scans the corresponding subnet to induce ARP entries, then polls each IP
  for forwarding information.
  """
  @spec discover(String.t, String.t) :: [Giraphe.Switch.t]

  def discover(subnet, gateway_address)
      when is_binary(subnet)
       and is_binary(gateway_address)
  do
    :ok = Giraphe.IO.ping_subnet NetAddr.ip(subnet)

    gateway_address = NetAddr.ip gateway_address

    arp_entries =
      gateway_address
        |> Giraphe.IO.get_target_arp_cache
        |> Enum.into(%{})

    arp_entries
      |> Utility.unzip_and_get_elem(0)
      |> Enum.filter(&(&1 != gateway_address))
      |> fetch_switches(arp_entries[gateway_address])
      |> Enum.sort_by(&(&1.polladdr))
  end
end
