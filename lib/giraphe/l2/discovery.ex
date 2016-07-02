# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Discovery do
  import Giraphe.Utility

  require Logger

  alias Giraphe.IO

  defp find_switches_with_non_nil_fdbs(switches) do
    Stream.filter switches, fn %{fdb: nil} -> false; _ -> true end
  end

  defp get_switchport_by_physaddr(switch, physaddr) do
    Enum.find_value switch.fdb, fn {p, ^physaddr} -> p; _ -> nil end
  end

  def fetch_switches(targets, gateway_physaddr) do
    targets
      |> Enum.map(&IO.get_switch(&1))
      |> find_switches_with_non_nil_fdbs
      |> Enum.map(fn s ->
        uplink = get_switchport_by_physaddr s, gateway_physaddr

        %{s | uplink: uplink}
      end)
  end

  defp find_connected_routes(routes) do
    Enum.filter routes, fn {_, "0.0.0.0"} -> true; _ -> false end
  end

  @spec discover(String.t) :: [Giraphe.Switch.t]
  def discover(gateway_address) do
    subnet =
      gateway_address
        |> IO.get_target_routes
        |> find_connected_routes
        |> get_destinations_from_routes
        |> sort_prefixes_by_length_descending
        |> find_prefix_containing_address(gateway_address)

    discover subnet, gateway_address
  end

  @spec discover(String.t, String.t) :: [Giraphe.Switch.t]
  def discover(subnet, gateway_address) do
    :ok = IO.ping_subnet subnet

    arp_entries =
      gateway_address
        |> IO.get_target_arp_cache
        |> Enum.into(%{})

    arp_entries
      |> Enum.unzip
      |> elem(0)
      |> Enum.filter(&(&1 != gateway_address))
      |> fetch_switches(arp_entries[gateway_address])
      |> sort_devices_by_polladdr_ascending
  end
end
