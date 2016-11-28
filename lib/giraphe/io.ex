# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO do
  @moduledoc false

  alias Giraphe.Utility

  require Logger

  defp get_query_output(query_result, default_fun) do
    case query_result do
      {:ok, _, _, output} ->
        output

      {:error, target, object, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}' for object '#{object}': #{inspect reason}"

        default_fun.(target, reason)
    end
  end

  defp query(object, target, default_fun) do
    object
      |> Giraphe.IO.Query.query(target)
      |> get_query_output(default_fun)
  end

  def credentials do
    Application.get_env :giraphe, :credentials
  end

  defp find_connected_route_containing_address(routes, address) do
    Enum.find routes, fn {destination, next_hop} ->
      NetAddr.contains?(destination, address)
        && Utility.next_hop_is_self(next_hop)
    end
  end

  defp find_addresses_with_matching_connected_routes(addresses, []) do
    addresses
  end
  defp find_addresses_with_matching_connected_routes(addresses, routes) do
    Enum.filter addresses, &find_connected_route_containing_address(routes, &1)
  end

  def get_router(target) do
    if is_snmp_agent(target) do
      routes = get_target_routes(target)
      addresses = get_target_addresses(target)

      # Nexus can have routes that don't correspond to addresses
      addresses =
        if length(routes) <= length(addresses) do
          addresses
        else
          find_addresses_with_matching_connected_routes(addresses, routes)
        end

      routes =
        if length(routes) <= length(addresses) do
          Enum.map(addresses, fn a ->
            {NetAddr.first_address(a), address_to_next_hop_self(a)}
          end)
        else
          routes
        end

      polladdr = Utility.refine_address_length target, addresses, routes

      %Giraphe.Router{
         polladdr: polladdr,
        addresses: addresses,
           routes: routes,
             name: get_target_sysname(target)
      }

    else
      %Giraphe.Router{
         polladdr: target,
        addresses: [target],
           routes: [{target, address_to_next_hop_self(target)}],
             name: NetAddr.address(target)
      }
    end
  end

  defp get_switchport_by_mac(switch, mac) do
    fdb = Enum.filter switch.fdb, fn {_, a, _} -> a != switch.physaddr end

    Enum.find_value fdb, fn {p, ^mac, _} -> p; _ -> nil end
  end

  def get_switch(target, physaddr, gateway_mac) do
    switch = %Giraphe.Switch{polladdr: target, physaddr: physaddr}

    if is_snmp_agent(target) do
      switch =
        %{switch |
          name: get_target_sysname(target),
           fdb: get_target_fdb(target)
        }

      %{switch | uplink: get_switchport_by_mac(switch, gateway_mac)}

    else
      %{switch |
        name: NetAddr.address(target),
        fdb: []
      }
    end
  end

  def get_target_addresses(target) do
    Enum.sort query(:addresses, target, fn(t, _) -> [t] end)
  end

  def get_target_arp_cache(target) do
    Enum.sort query(:arp_cache, target, fn(_, _) -> [] end)
  end

  def get_target_fdb(target) do
    query(:fdb, target, fn(_, _) -> [] end)
  end

  defp address_to_next_hop_self(address) do
    List.duplicate(0, NetAddr.address_size address)
      |> :binary.list_to_bin
      |> NetAddr.netaddr
  end

  def get_target_routes(target) do
    :routes
      |> query(target, fn(_, _) -> [] end)
      |> Enum.sort
  end

  def get_target_sysname(target) do
    query(:sysname, target, fn(t, _) -> NetAddr.address(t) end)
  end

  def ping_subnet(subnet) do
    Giraphe.IO.HostScan.scan subnet
  end

  def is_snmp_agent(%{} = target) do
    Giraphe.IO.HostScan.udp_161_open? target
  end
  def is_snmp_agent(_), do: false
end
