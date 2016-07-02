# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Discovery do
  require Logger

  import Giraphe.IO
  import Giraphe.Utility

  alias Giraphe.Switch

  defp get_switchport_by_physaddr(switch, physaddr) do
    Enum.find_value switch.fdb, fn {p, ^physaddr} -> p; _ -> nil end
  end

  defp remove_arp_entries_by_netaddr(arp_entries, netaddr) do
    Enum.filter arp_entries, fn {^netaddr, _} -> false; _ -> true end
  end

  defp find_switches_with_non_nil_fdbs(switches) do
    Stream.filter switches, fn %{fdb: nil} -> false; _ -> true end
  end

  defp find_connected_routes(routes) do
    Enum.filter routes, fn {_, "0.0.0.0"} -> true; _ -> false end
  end

  def discover(gateway_address) do
    subnet =
      gateway_address
        |> get_target_routes
        |> find_connected_routes
        |> get_destinations_from_routes
        |> sort_prefixes_by_length_descending
        |> find_prefix_containing_address(gateway_address)

    discover subnet, gateway_address
  end

  def discover(subnet, gateway_address) do
    :ok = ping_subnet subnet

    arp_entries =
      gateway_address
        |> get_target_arp_cache
        |> Enum.into(%{})

    targets =
      arp_entries
        |> Enum.unzip
        |> elem(0)
        |> remove_arp_entries_by_netaddr(gateway_address)

    targets
      |> Stream.map(fn t -> %Switch{polladdr: t} end)
      |> Stream.map(fn s -> %{s | physaddr: arp_entries[s.polladdr]} end)
      |> Stream.map(fn s -> %{s | name: get_target_sysname(s.polladdr)} end)
      |> Stream.map(fn s -> %{s | fdb: get_target_fdb(s.polladdr)} end)
      |> find_switches_with_non_nil_fdbs
      |> Enum.map(fn s ->
        uplink = get_switchport_by_physaddr s, arp_entries[gateway_address]

        %{s | uplink: uplink}
      end)
      |> sort_devices_by_polladdr_ascending
  end
end
