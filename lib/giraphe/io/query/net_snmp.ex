# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.Query.NetSNMP do
  @moduledoc """
  A net_snmp_ex implementation of the `Giraphe.IO.Querier` behaviour.
  """

  @behaviour Giraphe.IO.Query

  require Logger

  defp get_agent(target) do
    URI.parse "snmp://#{target}"
  end

  defp _try_credentials([], _fun, acc) do
    acc
  end
  defp _try_credentials([credential | tail], fun, acc) do
    with [{:error, reason} = error] <- fun.(credential) do
      :ok = Logger.info "Query failed using credential '#{inspect credential}': #{reason}."

      _try_credentials tail, fun, [error | acc]
    end
  end

  defp try_credentials(fun) do
    Keyword.get_values(Giraphe.IO.credentials, :snmp)
      |> Enum.map(&NetSNMP.credential/1)
      |> _try_credentials(fun, [])
  end

  defp snmpget(snmp_object, target, context \\ "")
  defp snmpget(snmp_object, target, context) do
    try_credentials &NetSNMP.get(snmp_object, get_agent(target), &1, context)
  end

  defp snmptable(snmp_object, target, context \\ "")
  defp snmptable(snmp_object, target, context) do
    try_credentials &NetSNMP.table(snmp_object, get_agent(target), &1, context)
  end

  defp dot1d_base_port_table_object do
    SNMPMIB.object "1.3.6.1.2.1.17.1.4", :any, nil
  end

  defp dot1d_tp_fdb_table_object do
    SNMPMIB.object "1.3.6.1.2.1.17.4.3", :any, nil
  end

  defp if_x_table_object do
    SNMPMIB.object "1.3.6.1.2.1.31.1.1", :any, nil
  end

  defp ip_addr_table_object do
    SNMPMIB.object "1.3.6.1.2.1.4.20", :any, nil
  end

  defp ip_cidr_route_table_object do
    SNMPMIB.object "1.3.6.1.2.1.4.24.4", :any, nil
  end

  defp ip_net_to_media_table_object do
    SNMPMIB.object "1.3.6.1.2.1.4.22", :any, nil
  end

  defp sysname_object do
    SNMPMIB.object "1.3.6.1.2.1.1.5.0", :string, nil
  end

  defp vtp_vlan_table_object do
    SNMPMIB.object "1.3.6.1.4.1.9.9.46.1.3.1", :any, nil
  end

  defp vlan_id_to_context(vlan_id) do
    "vlan-#{vlan_id}"
  end

  defp get_fdb_by_vlan_id(target, vlan_id) when is_integer vlan_id do
    context = vlan_id_to_context vlan_id

    case snmptable(dot1d_tp_fdb_table_object, target, context)do
      [] ->
        :ok = Logger.info "No FDB entries for VLAN #{vlan_id} on '#{target}'."

        []

      [{:error, reason} | _] = error ->
        :ok = Logger.debug "Unable to query FDB for '#{target}' on VLAN '#{inspect vlan_id}': #{reason}."

        error

      rows ->
        for row <- rows do
          {String.to_integer(row.port), NetAddr.mac_48(row.address), vlan_id}
        end
    end
  end

  defp get_port_mappings_by_vlan_id(target, vlan_id) when is_integer vlan_id do
    context = vlan_id_to_context vlan_id

    case snmptable(dot1d_base_port_table_object, target, context) do
      [] ->
        :ok = Logger.info "No port mappings for VLAN #{vlan_id} on '#{target}'."

        []

      [{:error, reason} | _] = error ->
        :ok = Logger.debug "Unable to query dot1dBasePortTable for '#{target}' on VLAN '#{inspect vlan_id}': #{reason}."

        error

      rows ->
        for row <- rows, into: %{} do
          port_index = String.replace row.index, ~r/\[|\]/, ""

          {String.to_integer(port_index), String.to_integer(row.ifindex)}
        end
    end
  end

  defp port_index_to_ifindex_map(target) do
    _query(:vlans, target)
      |> Enum.filter(fn {:error, _} -> false; _ -> true end)
      |> Enum.reduce(%{}, fn(vlan_id, acc) ->
        with %{} = map <- get_port_mappings_by_vlan_id(target, vlan_id)
        do
          Map.merge acc, map
        end
      end)
  end

  defp ifindex_to_interface_map(target) do
    case _query :interfaces, target do
      [error: reason] ->
        :ok = Logger.debug "Unable to query ifXTable for '#{target}': #{reason}."

        [error: reason]

      rows ->
        for row <- rows, into: %{}, do: {row.index, row}
    end
  end

  defp _query(:addresses, target) do
    with [%{} | _] = rows <- snmptable(ip_addr_table_object, target)
    do
      Enum.map rows, &NetAddr.ip(&1.addr, &1.netmask)
    end
  end
  defp _query(:arp_cache, target) do
    with [%{} | _] = rows <- snmptable(ip_net_to_media_table_object, target)
    do
      Enum.map rows, fn row ->
        {NetAddr.ip(row.netaddress), NetAddr.mac_48(row.physaddress)}
      end
    end
  end
  defp _query(:fdb, target) do
    {fdb_entries, errors} =
      _query(:vlans, target)
        |> Stream.filter(fn {:error, _} -> false; _ -> true end)
        |> Stream.flat_map(&get_fdb_by_vlan_id(target, &1))
        |> Enum.partition(fn {:error, _} -> false; _ -> true end)

    with [{_, _, _} | _] = fdb_entries <- errors ++ fdb_entries,
         %{} = port_to_ifindex      <- port_index_to_ifindex_map(target),
         %{} = ifindex_to_interface <- ifindex_to_interface_map(target)
    do
      for {port, address, vlan} <- fdb_entries do
        ifindex = port_to_ifindex[port]

        if interface = ifindex_to_interface[ifindex] do
          {interface.name, address, vlan}

        else
          :ok = Logger.debug "Unable to resolve interface for {#{port}, #{address}, #{vlan}}."

          nil
        end
      end |> Enum.filter(&(&1))
    end
  end
  defp _query(:interfaces, target) do
    with [%{} | _] = rows <- snmptable(if_x_table_object, target)
    do
      for row <- rows do
        index =
          row.index
            |> String.replace(~r/\[|\]/, "")
            |> String.to_integer

        %{row | index: index}
      end
    end
  end
  defp _query(:routes, target) do
    with [%{} | _] = rows <- snmptable(ip_cidr_route_table_object, target)
    do
      Enum.map(rows, & {NetAddr.ip(&1.dest, &1.mask), NetAddr.ip(&1.nexthop)})
    end
  end
  defp _query(:sysname, target) do
    with [ok: %{value: sysname}] <- snmpget(sysname_object, target)
    do
      sysname
    end
  end
  defp _query(:vlans, target) do
    with [%{} | _] = rows <- snmptable(vtp_vlan_table_object, target)
    do
      for row <- rows do
        [_, vlan] = Regex.run ~r/^.*\[(\d+)\]$/, row.index

        String.to_integer vlan
      end
    end
  end

  def query(object, target) do
    case _query(object, target) do
      [{:error, reason} | _] ->
        {:error, target, object, reason}

      result ->
        if result == [] do
          :ok = Logger.warn("Got empty result for object #{object} on target #{target}")
        end

        {:ok, target, object, result}
    end
  end
end

