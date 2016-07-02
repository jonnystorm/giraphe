# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Dot do
  require EEx
  require Logger

  import Giraphe.Utility

  EEx.function_from_file(
    :defp, :generate_l3_dot,
      "templates/dot/l3_graph.dot.eex",
      [:routers, :subnets, :edges]
  )

  defp records_to_l3_edges(records) do
    Stream.map records, fn [router, subnet | _] -> {router, subnet} end
  end

  defp l3_edges_to_nodes(edges) do
    edges
      |> Enum.unzip
      |> Tuple.to_list
      |> Enum.map(&Enum.uniq/1)
      |> List.to_tuple
  end

  defp get_l3_edges(routers) do
    routers
      |> Enum.flat_map(fn r ->
        %{name: r.name, id: r.polladdr}
          |> List.duplicate(length r.addresses)
          |> Enum.zip(r.addresses)
      end)
      |> Enum.map(fn {router, address} ->
        subnet = get_prefix_from_address address

        {router, subnet}
      end)
  end

  defp sort_prefixes_ascending(prefixes) do
    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128"
    max_length  = String.length ipv6_string

    Enum.sort prefixes, fn(p1, p2) ->
      sort_key1 = String.rjust p1, max_length
      sort_key2 = String.rjust p2, max_length

      sort_key1 < sort_key2
    end
  end

  defp sort_l3_edges_by_router_id_and_subnet(edges) do
    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128"
    max_lengths = List.duplicate String.length(ipv6_string), 2

    Enum.sort edges, fn({r1, s1}, {r2, s2}) ->
      sort_key1 = rjust_and_concat [r1[:id], s1], max_lengths
      sort_key2 = rjust_and_concat [r2[:id], s2], max_lengths

      sort_key1 < sort_key2
    end
  end

  defp graph_from_edges(edges) do
    {routers, subnets} = l3_edges_to_nodes edges

    subnets = sort_prefixes_ascending subnets

    generate_l3_dot routers, subnets, edges
  end

  def graph_from_routers(routers) do
    routers
      |> get_l3_edges
      |> sort_l3_edges_by_router_id_and_subnet
      |> graph_from_edges
  end

  defp get_record_stream(path) do
    path
      |> Path.expand
      |> File.stream!
      |> Stream.map(&String.strip/1)
      |> Stream.map(&String.split/1)
  end

  def graph_from_file(path) do
    path
      |> get_record_stream
      |> records_to_l3_edges
      |> graph_from_edges
  end
end
