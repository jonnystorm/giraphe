# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Utility do
  @moduledoc false

  require Logger

  def quiet? do
    Application.get_env :giraphe, :quiet
  end

  def status(message) do
    if not quiet? do
      IO.puts :stderr, message
    end
  end

  def find_prefix_containing_address(prefixes, address) do
    Enum.find(prefixes, &NetAddr.contains?(&1, address))
  end

  def find_route_containing_address(routes, address) do
    Enum.find(routes, fn {dest, _} -> NetAddr.contains?(dest, address) end)
  end

  def find_connected_route_containing_address(routes, address) do
    Enum.find(routes, fn {dest, next_hop} ->
        NetAddr.contains?(dest, address) && next_hop_is_self(next_hop)
    end)
  end

  def find_non_connected_routes(routes) do
    Enum.filter(routes, & !is_connected_route(&1))
  end

  def get_destinations_from_routes(routes) do
    routes
      |> unzip_and_get_elem(0)
      |> Enum.sort
      |> Enum.dedup
  end

  def get_next_hops_from_routes([]), do: []
  def get_next_hops_from_routes(routes) do
    routes
      |> unzip_and_get_elem(1)
      |> Enum.sort
      |> Enum.dedup
  end

  def is_connected_route({_destination, next_hop}) do
    next_hop_is_self(next_hop)
  end
  def is_connected_route(_), do: false

  def is_host_address(%{} = address) do
    NetAddr.first_address(address) == NetAddr.last_address(address)
  end
  def is_host_address(_), do: false

  def is_not_host_address(address) do
    not is_host_address address
  end

  def is_not_default_address(prefix) do
    (prefix != NetAddr.ip("0.0.0.0/0")) && (prefix != NetAddr.ip("::/0"))
  end

  def next_hop_is_self(address) do
    (NetAddr.ip("0.0.0.0") == address) || (NetAddr.ip("::") == address)
  end

  def next_hop_is_not_self(address) do
    not next_hop_is_self address
  end

  defp _lookup_route_recursive(routes, address) do
    with {dest, next_hop} <- find_route_containing_address(routes, address)
    do
      if next_hop_is_self(next_hop) or (dest == address) do
        dest

      else
        _lookup_route_recursive routes, next_hop
      end
    end
  end

  defp lookup_route_recursive(routes, address) do
    routes
      |> Enum.sort
      |> Enum.reverse
      |> _lookup_route_recursive(address)
  end

  defp set_address_length_to_matching_address_length(addresses, address) do
    if match = find_prefix_containing_address addresses, address do
      NetAddr.address_length address, NetAddr.address_length(match)

    else
      nil
    end
  end

  def refine_address_length(address, addresses, routes) do
    set_address_length_to_matching_address_length(addresses, address)
      || set_address_length_to_matching_address_length(
           [lookup_route_recursive(routes, address)],
           address
         )
      || address
  end

  def trim_domain_from_device_sysname(device) do
    if device.name == NetAddr.address(device.polladdr) do
      device

    else
      case Regex.run ~r/^(.*)\.[^\.]+\.[a-zA-Z\d]+$/, device.name do
        nil ->
          device

        [_, hostname] ->
          %{device | name: hostname}
      end
    end
  end

  def unzip_and_get_elem(zipped, e) do
    zipped
      |> Enum.unzip
      |> elem(e)
  end
end
