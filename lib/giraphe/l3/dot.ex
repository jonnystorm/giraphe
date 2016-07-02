# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.Dot do
  require Logger

  import Giraphe.Utility

  defp get_dot_template do
    Application.get_env :giraphe, :l3_dot_template
  end

  defp generate_dot(routers, subnets, edges) do
    EEx.eval_file(
      get_dot_template,
      [routers: routers, subnets: subnets, edges: edges]
    )
  end

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
    lengths = [String.length ipv6_string]

    Enum.sort_by prefixes, &rjust_and_concat([&1], lengths), &(&1 < &2)
  end

  defp sort_l3_edges_by_router_id_and_subnet(edges) do
    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128"
    lengths = List.duplicate String.length(ipv6_string), 2

    Enum.sort_by(
      edges,
      fn {r, s} -> rjust_and_concat [r[:id], s], lengths end,
      &(&1 < &2)
    )
  end

  defp graph_from_edges(edges) do
    {routers, subnets} = l3_edges_to_nodes edges

    subnets = sort_prefixes_ascending subnets

    generate_dot routers, subnets, edges
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
