# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Discover.L3 do
  @moduledoc """
  Discovery functions for routers.
  """

  # TODO: Replace route tuple with struct to ease future
  # additions

  alias Giraphe.Utility

  require Logger

  defp fetch_routers(targets),
    do: Enum.map(targets, &Giraphe.IO.get_router/1)

  defp any_similar_address?(addresses, address) do
    Enum.any? addresses,
      &(NetAddr.address(&1) == NetAddr.address(address))
  end

  defp find_old_router(routers, router) do
    case router do
      %{addresses: [address], routes: [_]} ->
        old_router =
          Enum.find routers, fn %{addresses: addresses} ->
            any_similar_address?(addresses, address)
          end

        old_router

      _ ->
        Enum.find routers, fn
          %{addresses: [address]} ->
            any_similar_address?(router.addresses, address)

          %{addresses: addresses} ->
            addresses == router.addresses
        end
    end
  end

  defp get_best_router(routers, new_router) do
    if old_router = find_old_router(routers, new_router) do
      best_router =
        Enum.max_by [old_router, new_router], fn r ->
          length(r.addresses) + length(r.routes)
        end

      case best_router do
        ^old_router ->
          {old_router, new_router}

        ^new_router ->
          {new_router, old_router}
      end

    else
      {new_router, nil}
    end
  end

  defp _filter_new_routers([], routers),
    do: Enum.reverse routers

  defp _filter_new_routers([new_router | tail], routers) do
    # TODO: Write tests that clearly express when this
    # heuristic is required

    case get_best_router(routers, new_router) do
      {^new_router, nil} ->
        :ok = Logger.debug("No loop detected: '#{new_router.name}'.")

        _filter_new_routers(tail, [new_router|routers])

      {^new_router, old_router} ->
        :ok = Logger.info("Loop: new '#{new_router.name}' usurps '#{old_router.name}'.")

        routers =
          [ new_router |
            Enum.filter(routers, &(&1 != old_router))
          ]

        _filter_new_routers(tail, routers)

      {old_router, new_router} ->
        :ok = Logger.info("Loop: incumbent '#{old_router.name}' defeats '#{new_router.name}'.")

        _filter_new_routers(tail, routers)
    end
  end

  defp filter_new_routers(new_routers),
    do: _filter_new_routers(new_routers, [])

  defp _get_next_targets_from_routers(routers) do
    for router <-
          routers,

        next_hop <-
          Utility.get_next_hops_from_routes(router.routes),

        Utility.next_hop_is_not_self(next_hop)
    do
      Utility.refine_address_length(
        next_hop,
        router.addresses,
        router.routes
      )
    end
  end

  defp get_next_targets_from_routers(routers) do
    routers
    |> _get_next_targets_from_routers
    |> Enum.filter(& &1)
    |> Enum.sort
    |> Enum.dedup
  end

  defp _discover([], routers),
    do: routers

  defp _discover(targets, routers) do
    new_routers =
      targets
      |> fetch_routers
      |> filter_new_routers

    all_routers = Enum.concat(routers, new_routers)
    next_targets =
      new_routers
      |> get_next_targets_from_routers
      |> Enum.filter(fn next_target ->
        not Enum.any?(all_routers, fn r ->
          any_similar_address?(r.addresses, next_target)
        end)
      end)

    new_names = Enum.map(new_routers, &(&1.name))

    Utility.status "New routers discovered: " <> Enum.join(new_names, ", ")
    Utility.status "Next targets: " <> Enum.join(next_targets, ", ")

    _discover(next_targets, all_routers)
  end

  defp get_default_gateway do
    {output, 0} = System.cmd("ip", ~w(route))

    ["default", "via", default_gateway | _] =
      output
      |> String.split("\n")
      |> Enum.filter(
        &String.starts_with?(&1, "default via ")
      )
      |> List.first
      |> String.split

    NetAddr.ip default_gateway
  end

  @doc """
  Discovers routers by polling `targets`.

  Additional routers are discovered by polling next-hops
  found in routing tables.
  """
  @spec discover([NetAddr.t]) :: [Giraphe.Router.t]
  def discover([]),
    do: discover [get_default_gateway()]

  def discover(targets) do
    Utility.status "Seeding targets " <> Enum.join(targets, ", ")

    targets
    |> _discover([])
    |> Enum.sort_by(& &1.polladdr)
  end
end
