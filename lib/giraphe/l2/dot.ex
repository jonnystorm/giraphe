# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.Dot do
  require EEx
  require Logger

  import Giraphe.Utility

  EEx.function_from_file(
    :defp, :generate_l2_dot,
      "templates/dot/l2_graph.dot.eex",
      [:switches, :edges]
  )

  defp get_switchport_by_physaddr(switch, physaddr) do
    Enum.find_value switch.fdb, fn {p, ^physaddr} -> p; _ -> nil end
  end

  defp get_downlink_from_edge({x, y}) do
    get_switchport_by_physaddr y, x.physaddr
  end

  defp max_string_length(strings) do
    strings
      |> Stream.map(&String.length(&1))
      |> Enum.max
  end

  defp sort_l2_edges_by_upstream_polladdr_and_downlink(edges) do
    downlinks =
      edges
        |> Stream.map(&({&1, get_downlink_from_edge(&1)}))
        |> Enum.into(%{})

    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128"
    max_polladdr_len = String.length ipv6_string
    max_downlink_len = max_string_length Map.values(downlinks)

    lengths = [max_polladdr_len, max_downlink_len]

    Enum.sort_by(
      edges,
      fn({_, u} = e) -> rjust_and_concat([u.polladdr, downlinks[e]], lengths) end,
      &(&1 < &2)
    )
  end

  defp physaddr_in_switch_fdb?(switch, physaddr) do
    get_switchport_by_physaddr(switch, physaddr) != nil
  end

  defp fdb_to_mapset(fdb) do
    fdb
      |> Enum.unzip
      |> elem(1)
      |> MapSet.new
  end

  defp fdb_proper_subset?(fdb1, fdb2) do
    set1 = fdb_to_mapset fdb1
    set2 = fdb_to_mapset fdb2

    MapSet.subset?(set1, set2) and not MapSet.equal?(set1, set2)
  end

  defp uniq_edges_by_min_of_fdb_entries_in_upstream_switches(edges) do
    edges
      |> Enum.group_by(fn {x, _} -> x end)
      |> Enum.map(fn {_, edges} ->
        Enum.min_by edges, fn {_, y} -> length(y.fdb) end
      end)
  end

  defp get_l2_edges(switches) do
    for x <- switches,
        y <- switches,
        fdb_proper_subset?(x.fdb, y.fdb),
        physaddr_in_switch_fdb?(y, x.physaddr)
    do
      {x, y}

    end |> uniq_edges_by_min_of_fdb_entries_in_upstream_switches
  end

  defp filter_switch_fdb(switch, fun) do
    filtered_fdb = Enum.filter switch.fdb, &fun.(&1)

    %{switch | fdb: filtered_fdb}
  end

  defp remove_switch_fdb_entries_by_port(switch, portname) do
    filter_switch_fdb switch, fn {^portname, _} -> false; _ -> true end
  end

  defp intersect_switch_fdb_entries_with_physaddrs(switch, physaddrs) do
    filter_switch_fdb switch, fn {_, pa} -> pa in physaddrs end
  end

  def digraph_from_switches(switches) do
    switch_physaddrs = Enum.map switches, &(&1.physaddr)

    switches =
      Enum.map switches, fn switch ->
        uplink = switch.uplink

        switch
          |> remove_switch_fdb_entries_by_port(uplink)
          |> intersect_switch_fdb_entries_with_physaddrs(switch_physaddrs)
      end

    edges =
      switches
        |> get_l2_edges
        |> sort_l2_edges_by_upstream_polladdr_and_downlink

    generate_l2_dot switches, edges
  end
end
