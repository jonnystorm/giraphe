# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Discovery do
  require Logger

  alias Giraphe.Utility

  def fetch_routers(targets) do
    Enum.map targets, &Giraphe.IO.get_router/1
  end

  defp gather_names_addresses_and_next_hops_from_routers(routers) do
    [names, address_lists, next_hop_lists] =
      routers
        |> Enum.map(fn r ->
          next_hops = Utility.get_next_hops_from_routes r.routes

          [r.name, r.addresses, next_hops]

      end)
      |> List.zip
      |> Enum.map(&Tuple.to_list/1)

    {names, address_lists, next_hop_lists}
  end

  defp get_targets_from_next_hop_lists(next_hop_lists) do
    next_hop_lists
      |> List.flatten
      |> Enum.sort
      |> Enum.dedup
      |> Enum.filter(&(&1 != "0.0.0.0"))
  end

  defp merge_list_with_map(list, map) do
    list
      |> Enum.map(&({&1, nil}))
      |> Enum.into(%{})
      |> Map.merge(map)
  end

  defp _discover([], {_, _, routers}) do
    routers
  end
  defp _discover(targets, {targets_seen, addresses_seen, routers}) do
    new_routers =
      targets
        |> fetch_routers
        |> Enum.filter(&(not Map.has_key? addresses_seen, &1.addresses))

    {new_names, new_addresses, new_next_hops} =
      gather_names_addresses_and_next_hops_from_routers new_routers

    next_targets =
      new_next_hops
        |> get_targets_from_next_hop_lists
        |> Enum.filter(&(not Map.has_key? targets_seen, &1))

    addresses_seen = merge_list_with_map new_addresses, addresses_seen
    targets_seen   = merge_list_with_map targets, targets_seen
    routers        = Enum.concat routers, new_routers

    :ok = Logger.info "New routers discovered: #{inspect new_names}"
    :ok = Logger.info "Next targets: #{inspect next_targets}"

    _discover next_targets, {targets_seen, addresses_seen, routers}
  end

  defp append_length_to_address(address, sorted_prefixes) do
    len =
      sorted_prefixes
        |> Utility.find_prefix_containing_address(address)
        |> Utility.get_prefix_length

    "#{address}/#{len}"
  end

  defp patch_missing_lengths_in_router_addresses(routers) do
    prefixes =
      routers
        |> Enum.flat_map(&(&1.routes))
        |> Utility.get_destinations_from_routes
        |> Utility.sort_prefixes_by_length_descending

    Enum.map routers, fn %{addresses: [head | _]} = r ->
      case String.split head, "/" do
        [address] ->
          %{r | addresses: [append_length_to_address(address, prefixes)]}

        _ ->
          r
      end
    end
  end

  defp get_default_gateway do
    {output, 0} = System.cmd "ip", ["route"]

    ["default", "via", default_gateway | _] =
      output
        |> String.split("\n")
        |> Enum.filter(&String.starts_with?(&1, "default via "))
        |> List.first
        |> String.split

    default_gateway
  end

  @spec discover :: [Giraphe.Router.t]
  def discover do
    discover [get_default_gateway]
  end

  @spec discover([String.t]) :: [Giraphe.Router.t]
  def discover(targets) do
    targets
      |> _discover({%{}, %{}, []})
      |> patch_missing_lengths_in_router_addresses
      |> Utility.sort_devices_by_polladdr_ascending
  end
end
