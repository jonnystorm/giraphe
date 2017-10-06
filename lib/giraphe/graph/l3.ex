# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Graph.L3 do
  @moduledoc """
  A Layer 3 grapher implementation.
  """

  alias Giraphe.{Router,Utility}

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

  defp _make_point_to_point_incidence(
    router,
    next_hop,
    make_nexthop_incidence?
  ) do
    pseudoedge =
      [router.polladdr, next_hop]
      |> Enum.sort
      |> Enum.join(":")

    pseudoincidences = [{router.polladdr, pseudoedge}]

    if make_nexthop_incidence? do
      [{next_hop, pseudoedge} | pseudoincidences]
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

  defp address_is_a_known_next_hop?(next_hops, address) do
    Map.has_key?(next_hops, NetAddr.address(address))
  end

  @doc """
  Generate abstract graph representation from `routers`.
  """
  def abduce_incidences(routers) do
    router_map =
      routers
      |> Enum.map(& {&1.polladdr, &1})
      |> Enum.into(%{})

    next_hops =
      router_map
      |> Map.values
      |> Enum.flat_map(& &1.routes)
      |> Enum.map(& {NetAddr.address(elem(&1, 1)), nil})
      |> Enum.into(%{})

    router_map
    |> Map.values
    |> Enum.sort_by(& &1.polladdr)
    |> Enum.flat_map(fn router ->
      point_to_point_incidences =
        router.routes
        |> get_point_to_point_next_hops
        |> Enum.flat_map(fn nh ->
          nh_router = router_map[nh]

          router
          |> make_point_to_point_incidence(nh, nh_router)
        end)

      # TODO: Clarify this heuristic.
      #
      # This heuristic can also be improved. Those addresses
      # for which we have non-connected routes elsewhere,
      # with next-hops matching this router, should be kept.
      # In other words, if other routers on the network
      # corroborate this router's addresses, then we have
      # sufficient evidence to believe this router has the
      # addresses it alleges. We need not only acknowledge
      # addresses that are themselves next-hops.
      #
      addresses =
        Enum.filter router.addresses, fn a ->
          Router.has_connected_route_for_address?(router, a)
          && ( Router.is_not_an_island?(router)
               || address_is_a_known_next_hop?(next_hops, a)
             )
        end

      router.polladdr
      |> List.duplicate(length addresses)
      |> Stream.zip(addresses)
      |> Stream.map(fn {polladdr, subnet} ->
        {polladdr, NetAddr.first_address(subnet)}
      end)
      |> Stream.dedup
      |> Stream.concat(point_to_point_incidences)
      |> Enum.map(fn {polladdr, subnet} ->
        {NetAddr.address(polladdr), subnet}
      end)
    end)
    |> group_incidences_by_subnet
    |> find_incidence_groups_with_at_least_two_incidences
    |> Stream.flat_map(fn {_, incidences} -> incidences end)
    |> Enum.sort
    |> Enum.dedup
  end

  def graph_devices(routers, timestamp, template) do
    incidences = abduce_incidences routers

    Utility.evaluate_l3_template(
      incidences,
      routers,
      template,
      timestamp
    )
  end
end
