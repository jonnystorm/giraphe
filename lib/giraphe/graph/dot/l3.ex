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

  defp generate_dot(template, routers, edges, incidences, timestamp) do
    EEx.eval_file(
      template,
      [routers: routers, edges: edges, incidences: incidences, timestamp: timestamp]
    )
  end

  defp group_incidences_by_subnet(incidences) do
    Enum.group_by incidences, &elem(&1, 1)
  end

  defp find_incidence_groups_with_at_least_two_incidences(groups) do
    Stream.filter groups, fn {_, [_, _ | _]} -> true; _ -> false end
  end

  defp get_point_to_point_next_hops(routes) do
    routes
      |> Enum.filter(fn {nh, nh} -> true; _ -> false end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort
      |> Enum.dedup
  end

  defp join_sorted(list, delimiter) do
    list
      |> Enum.sort
      |> Enum.join(delimiter)
  end

  defp _make_point_to_point_incidence(router, next_hop, make_nh_incidence?) do
    pseudonode = join_sorted([router.polladdr, next_hop], ":")
    pseudoincidences = [{router.polladdr, pseudonode}]

    if make_nh_incidence? do
      [{next_hop, pseudonode} | pseudoincidences]

    else
      pseudoincidences
    end
  end

  defp make_point_to_point_incidence(router, next_hop, nil) do
    _make_point_to_point_incidence(router, next_hop, true)
  end
  defp make_point_to_point_incidence(router, _, %{polladdr: next_hop}) do
    _make_point_to_point_incidence(router, next_hop, false)
  end

  defp get_l3_incidences(routers) do
    routers
      |> Map.values
      |> Enum.sort_by(& &1.polladdr)
      |> Enum.flat_map(fn router ->
        point_to_point_incidences =
          router.routes
            |> get_point_to_point_next_hops
            |> Enum.flat_map(fn nh ->
              make_point_to_point_incidence(router, nh, routers[nh])
            end)

        addresses = Enum.filter(router.addresses, fn a ->
          Utility.find_connected_route_containing_address(router.routes, a)
        end)

        router.polladdr
          |> List.duplicate(length addresses)
          |> Stream.zip(addresses)
          |> Stream.map(fn {r, s} -> {r, NetAddr.first_address(s)} end)
          |> Stream.dedup
          |> Stream.concat(point_to_point_incidences)
          |> Enum.map(fn {r, s} -> {NetAddr.address(r), s} end)
      end)
      |> group_incidences_by_subnet
      |> find_incidence_groups_with_at_least_two_incidences
      |> Stream.flat_map(fn {_, incidences} -> incidences end)
      |> Enum.sort
      |> Enum.dedup
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
    incidences =
      routers
        |> Enum.map(& {&1.polladdr, &1})
        |> Enum.into(%{})
        |> get_l3_incidences

    graph_routers_and_incidences(routers, incidences, timestamp, template)
  end

  defp l3_incidences_to_nodes(incidences) do
    incidences
      |> Enum.unzip
      |> Tuple.to_list
      |> Enum.map(&Enum.uniq/1)
      |> List.to_tuple
  end

  defp router_to_node(router) do
    %{name: name} = Utility.trim_domain_from_device_sysname router

    %{name: name, id: NetAddr.address(router.polladdr)}
  end

  defp graph_routers_and_incidences(routers, incidences, timestamp, template) do
    router_nodes =
      routers
        |> Enum.map(&router_to_node/1)
        |> Enum.sort_by(& &1.id)

    edge_nodes =
      incidences
        |> Stream.map(&elem(&1, 1))
        |> Enum.sort
        |> Enum.map(fn <<_::binary>> = s -> s; s -> NetAddr.prefix(s) end)
        |> Enum.dedup

    incidences = Enum.map(incidences, fn
      {router, <<_::binary>> = edge} ->
        {router, edge}

      {router, edge} ->
        {router, NetAddr.prefix(edge)}
    end)

    generate_dot template, router_nodes, edge_nodes, incidences, timestamp
  end

  defp graph_incidences(incidences, timestamp, template) do
    {routers, _} = l3_incidences_to_nodes(incidences)

    graph_routers_and_incidences(routers, incidences, timestamp, template)
  end

  defp records_to_l3_incidences(records) do
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
      |> records_to_l3_incidences
      |> graph_incidences("#{DateTime.utc_now}", template)
  end
end
