# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Discovery do
  @moduledoc """
  Discovery functions for routers.
  """

  require Logger

  alias Giraphe.Utility

  defp fetch_routers(targets) do
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
      |> Enum.filter(&Utility.next_hop_is_not_self/1)
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

  defp refine_address_length(address, sorted_prefixes) do
    prefix = Utility.find_prefix_containing_address sorted_prefixes, address

    if prefix do
      NetAddr.address_length address, NetAddr.address_length(prefix)

    else
      address
    end
  end

  defp patch_missing_lengths_in_router_addresses(routers) do
    prefixes =
      routers
        |> Enum.flat_map(&(&1.routes))
        |> Utility.get_destinations_from_routes
        |> Enum.sort

    Enum.map routers, fn
      %{addresses: [head]} = r ->
        if Utility.is_host_address(head) do
          %{r | addresses: [refine_address_length(head, prefixes)]}

        else
          r
        end

      r ->
        r
    end
  end

  defp get_default_gateway do
    {output, 0} = System.cmd "ip", ~w(route)

    ["default", "via", default_gateway | _] =
      output
        |> String.split("\n")
        |> Enum.filter(&String.starts_with?(&1, "default via "))
        |> List.first
        |> String.split

    default_gateway
  end

  @doc """
  Discovers routers by polling this machine's default gateway.

  Additional routers are discovered by polling next-hops found in routing tables.
  """
  @spec discover :: [Giraphe.Router.t]

  def discover do
    discover [get_default_gateway]
  end

  @doc """
  Discovers routers by polling `targets`.

  Additional routers are discovered by polling next-hops found in routing tables.
  """
  @spec discover([String.t]) :: [Giraphe.Router.t]

  def discover(targets) do
    targets
      |> Enum.map(&NetAddr.ip/1)
      |> _discover({%{}, %{}, []})
      |> patch_missing_lengths_in_router_addresses
      |> Enum.sort_by(&(&1.polladdr))
  end
end
