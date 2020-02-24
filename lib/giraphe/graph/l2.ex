# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Graph.L2 do
  @moduledoc """
  A Layer 2 grapher implementation.
  """

  alias Giraphe.{Switch, Utility}

  require Logger

  defp max_string_length(strings) do
    strings
    |> Stream.map(&String.length/1)
    |> Enum.max
  end

  defp pad_and_concat(strings, lengths) do
    strings
    |> Enum.zip(lengths)
    |> Enum.map_join(fn {string, string_length} ->
      String.pad_leading(string, string_length)
    end)
  end

  defp sort_adjacencies_by_upstream_polladdr_and_downlink(
    adjacencies
  ) do
    downlinks =
      adjacencies
      |> Stream.map(& {&1, get_adjacency_downlink(&1)})
      |> Enum.into(%{})

    ipv6_string = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"

    max_polladdr_length = String.length ipv6_string
    max_downlink_length =
      downlinks
      |> Map.values
      |> max_string_length

    lengths = [max_polladdr_length, max_downlink_length]

    Enum.sort_by adjacencies, fn
      {_, upstream_switch} = adjacency ->
        downlink = downlinks[adjacency]

        upstream_polladdr =
          NetAddr.address upstream_switch.polladdr

        [upstream_polladdr, downlink]
        |> pad_and_concat(lengths)
    end
  end

  defp get_adjacency_downlink(
    { down = _downstream_switch,
        up = _upstream_switch
    }
  ), do: get_fdb_port_by_physaddr(up.fdb, down.physaddr)

  defp get_fdb_port_by_physaddr(fdb, physaddr) do
    Enum.find_value fdb, fn
      {port, ^physaddr, _} ->
        port
      _ ->
        nil
    end
  end

  defp unique_adjacencies_by_topologically_closest_switches(
    adjacencies
  ) do
    # Downstream switches usually have many switches
    # upstream of them. For each downstream switch, we only
    # want the directly connected upstream switch.
    #
    # The adjacency whose upstream switch has the fewest FDB
    # entries must contain the topologically closest pair of
    # switches.
    #
    adjacencies
    |> Enum.group_by(fn {d = _downstream_switch, _} -> d end)
    |> Enum.map(fn {_, adjacencies_of_downstream_switch} ->
      adjacencies_of_downstream_switch
      |> Enum.min_by(fn {_, upstream_switch} ->
        length upstream_switch.fdb
      end)
    end)
  end

  defp physaddr_in_fdb?(fdb, physaddr),
    do: get_fdb_port_by_physaddr(fdb, physaddr) != nil

  defp _abduce_adjacencies(switches) do
    for down = _downstream_switch <- switches,
          up =   _upstream_switch <- switches,
        physaddr_in_fdb?(up.fdb, down.physaddr)
    do
      {down, up}
    end
    |> unique_adjacencies_by_topologically_closest_switches
  end

  defp filter_switch_fdb(switch, fun) do
    %{switch |
      fdb: Enum.filter(switch.fdb, &fun.(&1))
    }
  end

  defp remove_switch_fdb_entries_by_port(
    switch,
    portname
  ) do
    filter_switch_fdb switch, fn
      {^portname, _, _} ->
        false
      _ ->
        true
    end
  end

  defp intersect_fdb_entries_with_physaddrs(
    switch,
    physaddrs
  ) do
    filter_switch_fdb switch, fn
      {_, physaddr, _} ->
        physaddr in physaddrs
    end
  end

  defp prepare_switches_for_adjacency_abduction(switches) do
    physaddrs = Enum.map switches, & &1.physaddr

    Enum.map switches, fn switch ->
      switch
      |> remove_switch_fdb_entries_by_port(switch.uplink)
      |> intersect_fdb_entries_with_physaddrs(physaddrs)
      |> Utility.trim_domain_from_device_sysname
    end
  end

  @type switches    :: [Switch.t, ...]
  @type adjacencies :: [{Switch.t, Switch.t}, ...]

  @doc """
  Generate graph representation from `switches`.
  """
  @spec abduce_adjacencies(switches)
    :: adjacencies
  def abduce_adjacencies(switches) do
    :ok = Logger.debug("Graphing switches '#{inspect(switches)}'...")

    prepped_switches =
      prepare_switches_for_adjacency_abduction(switches)

    try do
      prepped_switches
      |> _abduce_adjacencies
      |> sort_adjacencies_by_upstream_polladdr_and_downlink
    rescue
      _ in Enum.EmptyError ->
        :ok = Logger.error("No switch adjacencies found")

        []
    end
  end
end
