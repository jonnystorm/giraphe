# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Discover.L2 do
  @moduledoc """
  Discovery functions for switches.
  """

  # TODO: Replace FDB entry tuples with structs to ease
  # future additions

  alias Giraphe.Switch
  alias Giraphe.Utility

  require Logger

  defp find_switches_with_non_empty_fdbs(switches) do
    Stream.filter switches, fn
      %{fdb: [{_, _, _} | _]} ->
        true
      _ ->
        false
    end
  end

  defp fetch_switches(hosts, gateway_mac) do
    :ok = Logger.debug "Fetching switches..."

    hosts
    |> Stream.map(fn host ->
      host.ip
      |> Giraphe.IO.fetch_switch(host.mac, gateway_mac)
    end)
    |> find_switches_with_non_empty_fdbs
    |> Enum.sort_by(& &1.polladdr)
  end

  defp get_subnet_by_gateway_address(gateway_address) do
    gateway_address
    |> Giraphe.IO.get_target_routes
    |> Enum.filter(fn {_, next_hop} ->
      Utility.address_is_self next_hop
    end)
    |> Utility.get_destinations_from_routes
    |> Enum.filter(& &1 != gateway_address)
    |> Enum.filter(&Utility.is_not_default_address/1)
    |> Enum.sort
    |> Enum.reverse
    |> Utility.find_prefix_containing_address(
      gateway_address
    )
  end

  @doc """
  Discover switches in subnet `subnet` by polling
  `gateway_address` ARP entries.

  Ping scans the corresponding subnet to induce ARP entries,
  then polls each IP for forwarding information.
  """
  @spec discover_switches(NetAddr.t, NetAddr.t | nil)
    :: [Switch.t]
  def discover_switches(gateway_address, nil) do
    subnet = get_subnet_by_gateway_address gateway_address

    if subnet do
      :ok = Utility.status "Found subnet '#{subnet}' for gateway '#{gateway_address}'."

      discover_switches(gateway_address, subnet)
    else
      raise "Unable to find subnet for gateway #{inspect gateway_address}"
    end
  end

  def discover_switches(gateway_address, subnet) do
    hosts =
      Giraphe.IO.enumerate_hosts(subnet, gateway_address)

    host_ips =
      hosts
      |> Enum.map(&NetAddr.address &1.ip)
      |> Enum.join(", ")

    :ok = Utility.status "Found the following hosts: #{host_ips}."

    gateway =
      Enum.find hosts,
        & &1.ip == gateway_address

    fetch_switches(hosts, gateway.mac)
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
