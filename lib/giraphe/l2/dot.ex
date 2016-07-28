# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Dot do
  @moduledoc """
  Functions for generating switch diagrams with GraphViz dot.
  """

  alias Giraphe.Utility

  defp get_dot_template do
    Application.get_env :giraphe, :l2_dot_template
  end

  defp generate_dot(switches, edges) do
    EEx.eval_file(
      get_dot_template,
      [switches: switches, edges: edges]
    )
  end

  defp max_string_length(strings) do
    strings
      |> Stream.map(&String.length/1)
      |> Enum.max
  end

  defp sort_l2_edges_by_upstream_polladdr_and_downlink(edges) do
    downlinks =
      edges
        |> Stream.map(&({&1, get_downlink_from_edge(&1)}))
        |> Enum.into(%{})

    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    max_polladdr_len = String.length ipv6_string
    max_downlink_len = max_string_length Map.values(downlinks)

    lengths = [max_polladdr_len, max_downlink_len]

    Enum.sort_by edges, fn({_, upstream_switch} = edge) ->
      downlink = downlinks[edge]

      Utility.rjust_and_concat [upstream_switch.polladdr, downlink], lengths
    end
  end

  defp get_downlink_from_edge({downstream_switch, upstream_switch}) do
    get_fdb_port_by_physaddr upstream_switch.fdb, downstream_switch.physaddr
  end

  defp get_fdb_port_by_physaddr(fdb, physaddr) do
    Enum.find_value fdb, fn {port, ^physaddr} -> port; _ -> nil end
  end

  defp physaddr_in_fdb?(fdb, physaddr) do
    get_fdb_port_by_physaddr(fdb, physaddr) != nil
  end

  defp fdb_to_mapset(fdb) do
    fdb
      |> Utility.unzip_and_get_elem(1)
      |> MapSet.new
  end

  defp proper_subset?(mapset1, mapset2) do
    MapSet.subset?(mapset1, mapset2) and not MapSet.equal?(mapset1, mapset2)
  end

  defp fdb_proper_subset?(fdb1, fdb2) do
    mapset1 = fdb_to_mapset fdb1
    mapset2 = fdb_to_mapset fdb2

    proper_subset? mapset1, mapset2
  end

  defp uniq_edges_by_min_of_fdb_entries_in_upstream_switches(edges) do
    edges
      |> Enum.group_by(fn {downstream_switch, _} -> downstream_switch end)
      |> Enum.map(fn {_, grouped_edges} ->
        Enum.min_by grouped_edges, fn {_, upstream_switch} ->
          length upstream_switch.fdb
        end
      end)
  end

  defp get_l2_edges(switches) do
    for downstream_switch <- switches,
        upstream_switch <- switches,
        fdb_proper_subset?(downstream_switch.fdb, upstream_switch.fdb),
        physaddr_in_fdb?(upstream_switch.fdb, downstream_switch.physaddr)
    do
      {downstream_switch, upstream_switch}

    end |> uniq_edges_by_min_of_fdb_entries_in_upstream_switches
  end

  defp filter_switch_fdb(switch, fun) do
    Map.put switch, :fdb, Enum.filter(switch.fdb, &fun.(&1))
  end

  defp remove_switch_fdb_entries_by_port(switch, portname) do
    filter_switch_fdb switch, fn {^portname, _} -> false; _ -> true end
  end

  defp intersect_switch_fdb_entries_with_physaddrs(switch, physaddrs) do
    filter_switch_fdb switch, fn {_, physaddr} -> physaddr in physaddrs end
  end

  @doc """
  Generate GraphViz dot from `switches`.
  """
  def generate_digraph_from_switches(switches) do
    switch_physaddrs = Enum.map switches, &(&1.physaddr)

    switches =
      Enum.map switches, fn switch ->
        switch
          |> remove_switch_fdb_entries_by_port(switch.uplink)
          |> intersect_switch_fdb_entries_with_physaddrs(switch_physaddrs)
          |> Map.put(:polladdr, NetAddr.address(switch.polladdr))
      end

    edges =
      switches
        |> get_l2_edges
        |> sort_l2_edges_by_upstream_polladdr_and_downlink

    generate_dot switches, edges
  end
end
