# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Dot do
  @moduledoc """
  Functions for generating router diagrams with GraphViz dot.
  """

  defp get_dot_template do
    Application.get_env :giraphe, :l3_dot_template
  end

  defp generate_dot(routers, subnets, edges) do
    EEx.eval_file(
      get_dot_template,
      [routers: routers, subnets: subnets, edges: edges]
    )
  end

  defp get_l3_edges(routers) do
    routers
      |> Enum.flat_map(fn router ->
        addresses = Enum.sort router.addresses

        %{name: router.name, id: NetAddr.address(router.polladdr)}
          |> List.duplicate(length addresses)
          |> Enum.zip(addresses)
      end)
  end

  @doc """
  Generate GraphViz dot from `routers`.
  """
  def generate_graph_from_routers(routers) do
    routers
      |> Enum.sort_by(&(&1.polladdr))
      |> get_l3_edges
      |> generate_graph_from_edges
  end

  defp l3_edges_to_nodes(edges) do
    edges
      |> Enum.unzip
      |> Tuple.to_list
      |> Enum.map(&Enum.uniq/1)
      |> List.to_tuple
  end

  defp generate_graph_from_edges(edges) do
    {routers, subnets} = l3_edges_to_nodes edges

    subnets =
      subnets
        |> Enum.sort
        |> Enum.map(&NetAddr.prefix/1)
        |> Enum.dedup

    edges = Enum.map edges, fn {router, subnet} ->
      {router, NetAddr.prefix(subnet)}
    end

    generate_dot routers, subnets, edges
  end

  defp records_to_l3_edges(records) do
    Stream.map records, fn [router, subnet | _] -> {router, subnet} end
  end

  defp get_record_stream(path) do
    path
      |> Path.expand
      |> File.stream!
      |> Stream.map(&String.strip/1)
      |> Stream.map(&String.split/1)
  end

  @doc """
  Generate GraphViz dot from the file at `path`.
  """
  def generate_graph_from_file(path) do
    path
      |> get_record_stream
      |> records_to_l3_edges
      |> generate_graph_from_edges
  end
end
