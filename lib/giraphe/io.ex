# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO do
  require Logger

  @l2_querier Application.get_env(:giraphe, :l2_querier)
  @l3_querier Application.get_env(:giraphe, :l3_querier)
  @host_scanner Application.get_env(:giraphe, :host_scanner)

  def get_target_addresses(target) do
    case @l3_querier.query_addresses target do
      {:ok, target_addresses} ->
        target_addresses

      {:error, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}': #{inspect reason}"

        [target]
    end
  end

  def get_target_arp_cache(target) do
    case @l3_querier.query_arp target do
      {:ok, target_arp} ->
        target_arp

      {:error, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}': #{inspect reason}"

        []
    end
  end

  def get_target_fdb(target) do
    case @l2_querier.query_fdb target do
      {:ok, target_fdb} ->
        target_fdb

      {:error, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}': #{inspect reason}"

        nil
    end
  end

  def get_target_routes(target) do
    case @l3_querier.query_routes target do
      {:ok, target_routes} ->
        target_routes

      {:error, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}': #{inspect reason}"

        []
    end
  end

  def get_target_sysname(target) do
    case @l3_querier.query_sysname target do
      {:ok, target_sysname} ->
        target_sysname

      {:error, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}': #{inspect reason}"

        target
    end
  end

  def ping_subnet(subnet) do
    @host_scanner.scan subnet
  end
end
