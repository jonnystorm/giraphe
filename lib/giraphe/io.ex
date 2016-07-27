# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO do
  @moduledoc false

  require Logger

  defp l2_querier do
    Application.get_env :giraphe, :l2_querier
  end

  defp l3_querier do
    Application.get_env :giraphe, :l3_querier
  end

  defp host_scanner do
    Application.get_env :giraphe, :host_scanner
  end

  defp get_query_output(query_result, default_fun) do
    case query_result do
      {:ok, _, _, output} ->
        output

      {:error, target, object, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}' for object '#{object}': #{inspect reason}"

        default_fun.(target, reason)
    end
  end

  defp query(:addresses, target) do
    target
      |> l3_querier.query_addresses
      |> get_query_output(fn(target, _) -> [target] end)
  end
  defp query(:arp_cache, target) do
    target
      |> l3_querier.query_arp
      |> get_query_output(fn(_, _) -> [] end)
  end
  defp query(:fdb, target) do
    target
      |> l2_querier.query_fdb
      |> get_query_output(fn(_, _) -> nil end)
  end
  defp query(:physaddr, target) do
    target
      |> l3_querier.query_physaddr
      |> get_query_output(fn(_, _) -> nil end)
  end
  defp query(:routes, target) do
    target
      |> l3_querier.query_routes
      |> get_query_output(fn(_, _) -> [] end)
  end
  defp query(:sysname, target) do
    target
      |> l3_querier.query_sysname
      |> get_query_output(fn(target, _) -> NetAddr.address(target) end)
  end

  def get_target_arp_cache(target) do
    query :arp_cache, target
  end

  def get_target_routes(target) do
    query :routes, target
  end

  def get_router(target) do
    %Giraphe.Router{
       polladdr: target,
      addresses: query(:addresses, target),
         routes: query(   :routes, target),
           name: query(  :sysname, target)
    }
  end

  def get_switch(target) do
    %Giraphe.Switch{
      polladdr: target,
      physaddr: query(:physaddr, target),
          name: query( :sysname, target),
           fdb: query(     :fdb, target)
    }
  end

  def ping_subnet(subnet) do
    host_scanner.scan subnet
  end
end
