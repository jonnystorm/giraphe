# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Utility do
  @moduledoc false

  require Logger

  def quiet? do
    Application.get_env :giraphe, :quiet
  end

  def status(message) do
    if not quiet?() do
      IO.puts :stderr, message
    end
  end

  def find_prefix_containing_address(prefixes, address) do
    Enum.find prefixes, &NetAddr.contains?(&1, address)
  end

  def find_route_containing_address(routes, address) do
    Enum.find routes, fn {dest, _} ->
      NetAddr.contains?(dest, address)
    end
  end

  def find_non_connected_routes(routes) do
    Enum.filter routes, & not is_connected_route(&1)
  end

  def get_destinations_from_routes(routes) do
    routes
    |> unzip_and_get_elem(0)
    |> Enum.sort
    |> Enum.dedup
  end

  def get_next_hops_from_routes([]),
    do: []

  def get_next_hops_from_routes(routes) do
    routes
    |> unzip_and_get_elem(1)
    |> Enum.sort
    |> Enum.dedup
  end

  def is_connected_route({_destination, next_hop}),
    do: next_hop_is_self next_hop

  def is_connected_route(_),
    do: false

  def is_host_address(%{} = address) do
    NetAddr.first_address(address)
    == NetAddr.last_address(address)
  end

  def is_host_address(_),
    do: false

  def is_not_host_address(address),
    do: not is_host_address(address)

  def is_not_default_address(prefix) do
    (   prefix != NetAddr.ip("0.0.0.0/0"))
    && (prefix != NetAddr.ip("::/0"))
  end

  def next_hop_is_self(address) do
    (   NetAddr.ip("0.0.0.0") == address)
    || (NetAddr.ip("::")      == address)
  end

  def next_hop_is_not_self(address) do
    not next_hop_is_self(address)
  end

  defp _lookup_route_recursive([], _address), do: nil
  defp _lookup_route_recursive(routes, address) do
    with {dest, next_hop} <-
           find_route_containing_address(routes, address)
    do
      if next_hop_is_self(next_hop) or (dest == address) do
        dest
      else
        routes
        |> Enum.filter(& &1 != {dest, next_hop})
        |> _lookup_route_recursive(next_hop)
      end
    end
  end

  def lookup_route_recursive(routes, address) do
    routes
    |> Enum.sort
    |> Enum.reverse
    |> _lookup_route_recursive(address)
  end

  defp set_address_length_to_matching_address_length(
    addresses,
    address
  ) do
    match =
      find_prefix_containing_address(addresses, address)

    if match do
      NetAddr.address_length(
        address,
        NetAddr.address_length(match)
      )
    else
      nil
    end
  end

  def refine_address_length(address, addresses, routes) do
    with nil <-
           set_address_length_to_matching_address_length(
             addresses,
             address
           ),

         nil <-
           set_address_length_to_matching_address_length(
             [lookup_route_recursive(routes, address)],
             address
           ),
    do: address
  end

  def trim_domain_from_device_sysname(device) do
    if device.name == NetAddr.address(device.polladdr) do
      device
    else
      re = ~r/^(.*)\.[^\.]+\.[a-zA-Z\d]+$/

      case Regex.run(re, device.name) do
        nil ->
          device

        [_, hostname] ->
          %{device|name: hostname}
      end
    end
  end

  def unzip_and_get_elem(zipped, e) do
    zipped
    |> Enum.unzip
    |> elem(e)
  end
end
