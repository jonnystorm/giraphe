# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Discovery do
  require Logger

  import Giraphe.IO
  import Giraphe.Utility

  alias Giraphe.Router

  def _discover([], {_, routers}) do
    routers
  end
  def _discover(targets, {addresses_seen, routers}) do
    new_routers =
      targets
        |> Stream.map(fn t -> %Router{polladdr: t} end)
        |> Stream.map(fn r -> %{r | addresses: get_target_addresses(r.polladdr)} end)
        |> Stream.filter(fn r -> not Map.has_key? addresses_seen, r.addresses end)
        |> Stream.map(fn r -> %{r | name: get_target_sysname(r.polladdr)} end)
        |> Enum.map(  fn r -> %{r | routes: get_target_routes(r.polladdr)} end)

    [new_names, new_addresses, new_next_hops] =
      new_routers
        |> Enum.map(fn r ->
          next_hops = get_next_hops_from_routes r.routes

          [r.name, r.addresses, next_hops]
        end)
        |> List.zip
        |> Enum.map(&Tuple.to_list/1)

    addresses_seen =
      new_addresses
        |> Enum.map(&({&1, nil}))
        |> Enum.into(%{})
        |> Map.merge(addresses_seen)

    next_targets =
      new_next_hops
        |> List.flatten
        |> Enum.filter(&(&1 != "0.0.0.0"))
        |> Enum.sort
        |> Enum.dedup

    routers = Enum.concat routers, new_routers

    :ok = Logger.info "New routers discovered: #{inspect new_names}"
    :ok = Logger.info "Next targets: #{inspect next_targets}"

    _discover next_targets, {addresses_seen, routers}
  end

  defp append_length_to_address(address, sorted_prefixes) do
    len =
      sorted_prefixes
        |> find_prefix_containing_address(address)
        |> get_prefix_length

    "#{address}/#{len}"
  end

  defp get_default_gateway do
    {output, 0} = System.cmd "ip", ["route"]

    ["default", "via", default_gateway | _] =
      output
        |> String.split("\n")
        |> Enum.filter(&String.starts_with?(&1, "default via"))
        |> List.first
        |> String.split

    default_gateway
  end

  @spec discover :: [Router.t]
  def discover do
    discover [get_default_gateway]
  end

  @spec discover([String.t]) :: [Router.t]
  def discover(targets) do
    routers = _discover targets, {%{}, []}

    prefixes =
      routers
        |> Enum.flat_map(&(&1.routes))
        |> get_destinations_from_routes
        |> sort_prefixes_by_length_descending

    routers
      |> Enum.map(fn %{addresses: [head | _]} = r ->
        case String.split head, "/" do
          [address] ->
            %{r | addresses: [append_length_to_address(address, prefixes)]}

          _ ->
            r
        end
      end)
      |> sort_devices_by_polladdr_ascending
  end
end
