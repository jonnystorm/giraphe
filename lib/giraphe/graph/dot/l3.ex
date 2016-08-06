# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Graph.Dot.L3 do
  @moduledoc """
  Functions for generating router diagrams with GraphViz dot.
  """

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

  defp get_l3_edges(routers) do
    routers
      |> Enum.flat_map(fn router ->
        router = Utility.trim_domain_from_device_sysname router

        %{name: router.name, id: NetAddr.address(router.polladdr)}
          |> List.duplicate(length router.addresses)
          |> Enum.zip(router.addresses)
      end)
      |> Enum.map(fn {r, s} -> {r, NetAddr.first_address(s)} end)
      |> group_edges_by_subnet
      |> find_edge_groups_with_at_least_two_edges
      |> Enum.flat_map(fn {_, edges} -> edges end)
      |> Enum.sort
  end

  @doc """
  Generate GraphViz dot from `routers`.
  """
  def graph_routers(routers, template) do
    graph_routers routers, "#{DateTime.utc_now}", template
  end

  @doc """
  Generate GraphViz dot from `routers` with timestamp.
  """
  def graph_routers(routers, timestamp, template) do
    routers
      |> Enum.sort_by(&(&1.polladdr))
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
        |> Enum.map(&NetAddr.prefix/1)
        |> Enum.dedup

    edges = Enum.map edges, fn {router, subnet} ->
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
