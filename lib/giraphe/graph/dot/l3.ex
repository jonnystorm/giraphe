# copyright © 2016 jonathan storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Graph.Dot.L3 do
  @moduledoc """
  A grapher implementation for GraphViz dot.
  """

  @behaviour Giraphe.Graph

  alias Giraphe.Utility

  defp generate_dot(template, routers, subnets, edges, timestamp) do
    EEx.eval_file(
      template,
      [routers: routers, subnets: subnets, edges: edges, timestamp: timestamp]
    )
  end

  defp group_edges_by_subnet(edges) do
    Enum.group_by edges, &elem(&1, 1)
  end

  defp find_edge_groups_with_at_least_two_edges(groups) do
    Enum.filter groups, fn {_, [_, _ | _]} -> true; _ -> false end
  end

  defp get_point_to_point_next_hops(routes) do
    routes
      |> Enum.filter(fn {nh, nh} -> true; _ -> false end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort
      |> Enum.dedup
  end

  defp router_to_node(router) do
    %{name: router.name, id: NetAddr.address(router.polladdr)}
  end

  defp join_sorted(list, delimiter) do
    list
      |> Enum.sort
      |> Enum.join(delimiter)
  end

  defp make_point_to_point_edge(router, router_node, next_hop, nil) do
    next_hop_router = %{name: "#{next_hop}", polladdr: next_hop}
    pseudonode = join_sorted([router.polladdr, next_hop_router.polladdr], ":")
    next_hop_node = router_to_node(next_hop_router)

    [{router_node, pseudonode}, {next_hop_node, pseudonode}]
  end
  defp make_point_to_point_edge(router, router_node, _next_hop, next_hop_router) do
    pseudonode = join_sorted([router.polladdr, next_hop_router.polladdr], ":")

    [{router_node, pseudonode}]
  end

  defp get_l3_edges(routers) do
    routers
      |> Map.values
      |> Enum.sort_by(& &1.polladdr)
      |> Enum.flat_map(fn router ->
        router = Utility.trim_domain_from_device_sysname router
        router_node = router_to_node(router)

        point_to_point_edges =
          router.routes
            |> get_point_to_point_next_hops
            |> Enum.flat_map(fn nh ->
              make_point_to_point_edge(router, router_node, nh, routers[nh])
            end)

        router_node
          |> List.duplicate(length router.addresses)
          |> Enum.zip(router.addresses)
          |> Enum.map(fn {r, s} -> {r, NetAddr.first_address(s)} end)
          |> Enum.concat(point_to_point_edges)
      end)
      |> group_edges_by_subnet
      |> find_edge_groups_with_at_least_two_edges
      |> Enum.flat_map(fn {_, edges} -> edges end)
      |> Enum.sort
  end

  @doc """
  Generate GraphViz dot from `routers`.
  """
  def graph_devices(routers, template) do
    graph_devices routers, "#{DateTime.utc_now}", template
  end

  @doc """
  Generate GraphViz dot from `routers` with timestamp.
  """
  def graph_devices(routers, timestamp, template) do
    routers
      |> Enum.map(& {&1.polladdr, &1})
      |> Enum.into(%{})
      |> get_l3_edges
      |> graph_edges(timestamp, template)
  end

  defp l3_edges_to_nodes(edges) do
    edges
      |> Enum.unzip
      |> Tuple.to_list
      |> Enum.map(&Enum.uniq/1)
      |> List.to_tuple
  end

  defp graph_edges(edges, timestamp, template) do
    {routers, subnets} = l3_edges_to_nodes edges

    subnets =
      subnets
        |> Enum.sort
        |> Enum.map(fn <<_::binary>> = s -> s; s -> NetAddr.prefix(s) end)
        |> Enum.dedup

    edges = Enum.map edges, fn
      {router, <<_::binary>> = subnet} ->
        {router, subnet}

      {router, subnet} ->
        {router, NetAddr.prefix(subnet)}
    end

    generate_dot template, routers, subnets, edges, timestamp
  end

  defp records_to_l3_edges(records) do
    Stream.map records, fn [router, subnet | _] -> {router, subnet} end
  end

  defp get_record_stream(path) do
    path
      |> Path.expand
      |> File.stream!
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split/1)
  end

  @doc """
  Generate GraphViz dot from the file at `path`.
  """
  def generate_graph_from_file(path, template) do
    path
      |> get_record_stream
      |> records_to_l3_edges
      |> graph_edges("#{DateTime.utc_now}", template)
  end
end
