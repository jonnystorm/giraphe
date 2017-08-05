# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Graph.L3 do
  @moduledoc """
  A Layer 3 grapher implementation.
  """

  alias Giraphe.Utility

  defp group_incidences_by_subnet(incidences) do
    Enum.group_by incidences, &elem(&1, 1)
  end

  defp find_incidence_groups_with_at_least_two_incidences(
    groups
  ) do
    Stream.filter groups, fn
      {_, [_, _ | _]} ->
        true
      _ ->
        false
    end
  end

  defp get_point_to_point_next_hops(routes) do
    routes
      |> Enum.filter(fn
        {nh, nh} ->
          true
        _ ->
          false
      end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort
      |> Enum.dedup
  end

  defp join_sorted(list, delimiter) do
    list
      |> Enum.sort
      |> Enum.join(delimiter)
  end

  defp _make_point_to_point_incidence(
    router,
    next_hop,
    make_nexthop_incidence?
  ) do
    pseudonode =
      join_sorted([router.polladdr, next_hop], ":")

    pseudoincidences = [{router.polladdr, pseudonode}]

    if make_nexthop_incidence? do
      [{next_hop, pseudonode} | pseudoincidences]
    else
      pseudoincidences
    end
  end

  defp make_point_to_point_incidence(
    router,
    next_hop,
    nil
  ) do
    _make_point_to_point_incidence(router, next_hop, true)
  end

  defp make_point_to_point_incidence(
    router,
    _,
    %{polladdr: next_hop}
  ) do
    _make_point_to_point_incidence(router, next_hop, false)
  end

  defp router_is_not_an_island?(router) do
    Utility.find_non_connected_routes(router.routes) != []
  end

  defp address_is_a_known_next_hop?(next_hops, address) do
    Map.has_key?(next_hops, NetAddr.address(address))
  end

  defp router_has_connected_route_for_address?(
    router,
    address
  ) do
    router.routes
    |> Enum.reverse
    |> Utility.find_route_containing_address(address)
    |> Utility.is_connected_route
  end

  defp get_l3_incidences(routers) do
    next_hops =
      routers
      |> Map.values
      |> Enum.flat_map(& &1.routes)
      |> Enum.map(& {NetAddr.address(elem(&1, 1)), nil})
      |> Enum.into(%{})

    routers
    |> Map.values
    |> Enum.sort_by(& &1.polladdr)
    |> Enum.flat_map(fn router ->
      point_to_point_incidences =
        router.routes
        |> get_point_to_point_next_hops
        |> Enum.flat_map(fn nh ->
          router
          |> make_point_to_point_incidence(nh, routers[nh])
        end)

      # TODO: clarify this heuristic
      addresses = Enum.filter router.addresses, fn a ->
        router_has_connected_route_for_address?(router, a)
        && ( router_is_not_an_island?(router)
             || address_is_a_known_next_hop?(next_hops, a)
           )
      end

      router.polladdr
      |> List.duplicate(length addresses)
      |> Stream.zip(addresses)
      |> Stream.map(fn {r, s} ->
        {r, NetAddr.first_address(s)}
      end)
      |> Stream.dedup
      |> Stream.concat(point_to_point_incidences)
      |> Enum.map(fn {r, s} ->
        {NetAddr.address(r), s}
      end)
    end)
    |> group_incidences_by_subnet
    |> find_incidence_groups_with_at_least_two_incidences
    |> Stream.flat_map(fn {_, incidences} -> incidences end)
    |> Enum.sort
    |> Enum.dedup
  end

  def graph_devices(routers, timestamp, template_path) do
    incidences = abduce_incidences routers

    Giraphe.evaluate_l3_template(
      incidences,
      routers,
      template_path,
      timestamp
    )
  end

  @doc """
  Generate abstract graph representation from `routers`.
  """
  def abduce_incidences(routers) do
    routers
      |> Enum.map(& {&1.polladdr, &1})
      |> Enum.into(%{})
      |> get_l3_incidences
  end
end
