# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.IO.Query.NetSNMP do
  @moduledoc """
  A net_snmp_ex implementation of the `Giraphe.IO.Querier` behaviour.
  """

  @behaviour Giraphe.IO.Query

  require Logger

  defp get_agent(target),
    do: URI.parse "snmp://#{target}"

  defp _try_credentials([], _fun, acc),
    do: acc

  defp _try_credentials([credential|tail], fun, acc) do
    with [{:error, reason} = error] <- fun.(credential)
    do
      :ok = Logger.info "Query failed using credential '#{inspect credential}': #{reason}."

      _try_credentials(tail, fun, [error|acc])
    end
  end

  defp try_credentials(fun) do
    Giraphe.IO.credentials
    |> Keyword.get_values(:snmp)
    |> Enum.map(&NetSNMP.credential/1)
    |> _try_credentials(fun, [])
  end

  defp snmpget(snmp_object, target, context \\ "")
  defp snmpget(snmp_object, target, context) do
    agent = get_agent target

    (&NetSNMP.get(snmp_object, agent, &1, context))
    |> try_credentials
  end

  defp snmptable(snmp_object, target, context \\ "")
  defp snmptable(snmp_object, target, context) do
    agent = get_agent target

    (&NetSNMP.table(snmp_object, agent, &1, context))
    |> try_credentials
  end

  defp dot1d_base_port_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.17.1.4", :any, nil)

  defp dot1d_tp_fdb_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.17.4.3", :any, nil)

  defp if_x_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.31.1.1", :any, nil)

  defp ip_addr_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.4.20", :any, nil)

  defp ip_cidr_route_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.4.24.4", :any, nil)

  defp ip_net_to_media_table_object,
    do: SNMPMIB.object("1.3.6.1.2.1.4.22", :any, nil)

  defp sysname_object,
    do: SNMPMIB.object("1.3.6.1.2.1.1.5.0", :string, nil)

  defp vtp_vlan_table_object do
    SNMPMIB.object("1.3.6.1.4.1.9.9.46.1.3.1", :any, nil)
  end

  defp vlan_id_to_context(vlan_id),
    do: "vlan-#{vlan_id}"

  defp get_fdb_by_vlan_id(target, vlan_id)
      when is_integer vlan_id
  do
    object = dot1d_tp_fdb_table_object()
    context = vlan_id_to_context vlan_id
    output = snmptable(object, target, context)

    case output do
      [] ->
        :ok = Logger.info "No FDB entries for VLAN #{vlan_id} on '#{target}'."

        []

      [{:error, reason}|_] = error ->
        :ok = Logger.debug "Unable to query FDB for '#{target}' on VLAN '#{inspect vlan_id}': #{reason}."

        error

      rows ->
        for row <- rows do
          { String.to_integer(row.port),
            NetAddr.mac_48(row.address),
            vlan_id
          }
        end
    end
  end

  defp get_port_mappings_by_vlan_id(target, vlan_id)
      when is_integer vlan_id
  do
    object = dot1d_base_port_table_object()
    context = vlan_id_to_context vlan_id
    output = snmptable(object, target, context)

    case output do
      [] ->
        :ok = Logger.info "No port mappings for VLAN #{vlan_id} on '#{target}'."

        []

      [{:error, reason} | _] = error ->
        :ok = Logger.debug "Unable to query dot1dBasePortTable for '#{target}' on VLAN '#{inspect vlan_id}': #{reason}."

        error

      rows ->
        for row <- rows, into: %{} do
          port_index =
            String.replace(row.index, ~r/\[|\]/, "")

          { String.to_integer(port_index),
            String.to_integer(row.ifindex)
          }
        end
    end
  end

  defp port_index_to_ifindex_map(target) do
    :vlans
    |> _query(target)
    |> Enum.filter(fn
      {:error, _} ->
        false
      _ ->
        true
    end)
    |> Enum.reduce(%{}, fn(vlan_id, acc) ->
      with %{} = map
            <- get_port_mappings_by_vlan_id(target, vlan_id)
      do
        Map.merge(acc, map)
      end
    end)
  end

  defp ifindex_to_interface_map(target) do
    case _query(:interfaces, target) do
      [error: reason] ->
        :ok = Logger.debug "Unable to query ifXTable for '#{target}': #{reason}."

        [error: reason]

      rows ->
        for row <- rows, into: %{},
          do: {row.index, row}
    end
  end

  defp _query(:addresses, target) do
    object = ip_addr_table_object()

    with [%{} | _] = rows
           <- snmptable(object, target)
    do
      Enum.map rows,
        &NetAddr.ip(&1.addr, &1.netmask)
    end
  end

  defp _query(:arp_cache, target) do
    object = ip_net_to_media_table_object()

    with [%{} | _] = rows <- snmptable(object, target)
    do
      Enum.map rows, fn row ->
        { NetAddr.ip(row.netaddress),
          NetAddr.mac_48(row.physaddress)
        }
      end
    end
  end

  defp _query(:fdb, target) do
    {fdb_entries, errors} =
      :vlans
      |> _query(target)
      |> Stream.filter(fn
        {:error, _} ->
          false
        _ ->
          true
      end)
      |> Stream.flat_map(&get_fdb_by_vlan_id(target, &1))
      |> Enum.partition(fn
        {:error, _} ->
          false
        _ ->
          true
      end)

    with [{_, _, _}|_] = fdb_entries
           <- errors ++ fdb_entries,

         %{} = port_to_ifindex
           <- port_index_to_ifindex_map(target),

         %{} = ifindex_to_interface
           <- ifindex_to_interface_map(target)
    do
      for {port, address, vlan} <- fdb_entries do
        ifindex = port_to_ifindex[port]

        if interface = ifindex_to_interface[ifindex] do
          {interface.name, address, vlan}
        else
          :ok = Logger.debug "Unable to resolve interface for {#{port}, #{address}, #{vlan}}."

          nil
        end
      end |> Enum.filter(& &1 != nil)
    end
  end

  defp _query(:interfaces, target) do
    object = if_x_table_object()

    with [%{} | _] = rows <- snmptable(object, target)
    do
      for row <- rows do
        index =
          row.index
          |> String.replace(~r/\[|\]/, "")
          |> String.to_integer

        %{row|index: index}
      end
    end
  end

  defp _query(:routes, target) do
    object = ip_cidr_route_table_object()

    with [%{} | _] = rows <- snmptable(object, target)
    do
      Enum.reduce rows, [], fn(row, acc) ->
        destination = NetAddr.ip(row.dest, row.mask)
        nexthop     = NetAddr.ip(row.nexthop)

        case {destination, nexthop} do
          {{:error, _}, _} ->
            :ok = Logger.warn "Received bad destination or mask from #{target}: #{row.dest}/#{row.mask} -> #{row.nexthop}"

            acc

          {_, {:error, _}} ->
            :ok = Logger.warn "Received bad nexthop from #{target}: #{row.dest}/#{row.mask} -> #{row.nexthop}"

            acc

          route ->
            [route|acc]
        end
      end
    end
  end

  defp _query(:sysname, target) do
    object = sysname_object()

    with [ok: %{value: sysname}] <- snmpget(object, target),
    do: sysname
  end

  defp _query(:vlans, target) do
    object = vtp_vlan_table_object()

    with [%{} | _] = rows <- snmptable(object, target)
    do
      for row <- rows do
        [_, vlan] = Regex.run(~r/^.*\[(\d+)\]$/, row.index)

        String.to_integer vlan
      end
    end
  end

  @type query_object
    :: :addresses
     | :arp_cache
     | :fdb
     | :routes
     | :sysname

  @type target :: NetAddr.t

  @spec query(query_object, target)
    :: {   :ok, target, query_object, any}
     | {:error, target, query_object, any}
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

