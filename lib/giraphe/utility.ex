# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Utility do
  @moduledoc false

  require Logger

  @spec credentials
    :: Keyword.t
  def credentials,
    do: Application.get_env(:giraphe, :credentials)

  @spec quiet?
    :: boolean
  def quiet?,
    do: Application.get_env :giraphe, :quiet

  @spec status(String.t)
    :: :ok
  def status(message) do
    if not quiet?(),
      do: :ok = IO.puts(:stderr, message)

    :ok
  end

  @type prefix   :: NetAddr.t
  @type address  :: NetAddr.t
  @type prefixes :: [prefix]

  @spec find_prefix_containing_address(prefixes, address)
    :: prefix
     | nil
  def find_prefix_containing_address(prefixes, address) do
    Enum.find prefixes,
      &NetAddr.contains?(&1, address)
  end

  @type destination :: NetAddr.t
  @type next_hop    :: NetAddr.t
  @type route       :: {destination, next_hop}
  @type routes      :: [route]

  @spec find_route_containing_address(routes, address)
    :: route
     | nil
  def find_route_containing_address(routes, address) do
    Enum.find routes, fn {destination, _} ->
      NetAddr.contains?(destination, address)
    end
  end

  @type destinations :: [destination]

  @spec get_destinations_from_routes(routes)
    :: destinations
  def get_destinations_from_routes(routes) do
    routes
    |> unzip_and_get_elem(0)
    |> Enum.sort
    |> Enum.dedup
  end

  @type next_hops :: [next_hop]

  @spec get_next_hops_from_routes(routes)
    :: next_hops
  def get_next_hops_from_routes([]),
    do: []

  def get_next_hops_from_routes(routes) do
    routes
    |> unzip_and_get_elem(1)
    |> Enum.sort
    |> Enum.dedup
  end

  @spec is_connected_route(route)
    :: boolean
  def is_connected_route(route) do
    case route do
      {_destination, next_hop} ->
        next_hop |> address_is_self

      _ ->
        false
    end
  end

  @spec is_host_address(address)
    :: boolean
  def is_host_address(%{} = address) do
    NetAddr.first_address(address)
    == NetAddr.last_address(address)
  end

  def is_host_address(_),
    do: false

  @spec is_not_host_address(address)
    :: boolean
  def is_not_host_address(address),
    do: ! is_host_address(address)

  @spec is_not_default_address(prefix)
    :: boolean
  def is_not_default_address(prefix) do
    (   prefix != NetAddr.ip("0.0.0.0/0"))
    && (prefix != NetAddr.ip("::/0"))
  end

  @spec address_is_self(address)
    :: boolean
  def address_is_self(address) do
    (   NetAddr.ip("0.0.0.0") == address)
    || (NetAddr.ip("::")      == address)
  end

  @spec address_is_not_self(address)
    :: boolean
  def address_is_not_self(address) do
    ! address_is_self(address)
  end

  @spec address_is_localhost(address)
    :: boolean
  def address_is_localhost(address) do
    localhost = NetAddr.ip("127.0.0.0/8")

    NetAddr.contains?(localhost, address)
  end

  @spec address_is_not_localhost(address)
    :: boolean
  def address_is_not_localhost(address),
    do: ! address_is_localhost(address)

  defp _lookup_route_recursive([], _address),
    do: nil

  defp _lookup_route_recursive(routes, address) do
    with {destination, next_hop} <-
           find_route_containing_address(routes, address)
    do
      if address_is_self(next_hop)
         or destination == address
      do
        destination
      else
        routes
        |> Enum.filter(& &1 != {destination, next_hop})
        |> _lookup_route_recursive(next_hop)
      end
    end
  end

  @spec lookup_route_recursive(routes, address)
    :: destination
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

  @type addresses :: [address]

  @spec refine_address_length(address, addresses, routes)
    :: address
  def refine_address_length(address, addresses, routes) do
    # We prefer addresses in the form of a prefix with ones
    # in the host portion because this provides context for
    # where in the network the address resides. Next-hops
    # from routes never come with this context, thus we may
    # shorten their lengths once we know the router's
    # addresses.
    #
    # If this address matches one of `addresses`, then we
    # can find the right prefix length there. Otherwise, we
    # perform a recursive route lookup to find the next best
    # thing: an overlapping destination whose prefix length
    # is as long (specific) as possible without being the
    # address, itself, and without using the trivial prefix
    # length of zero (as with the default route).
    # Unfortunately, if there are summary routes in the
    # network, we may erroneously use the prefix length from
    # one of those.
    #
    # When all else fails, we return the address untouched.
    #
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

  @type polladdr
    :: NetAddr.IPv4.t
     | NetAddr.IPv6.t

  @type device
    :: %{
      any => any,
      name: nil | String.t,
      polladdr: polladdr,
    }

  @spec trim_domain_from_device_sysname(device)
    :: device
  def trim_domain_from_device_sysname(device) do
    if device.name == NetAddr.address(device.polladdr) do
      device
    else
      regexp = ~r/^(.*)\.[^\.]+\.[a-zA-Z\d]+$/

      case Regex.run(regexp, device.name) do
        nil ->
          device

        [_, hostname] ->
          %{device|name: hostname}
      end
    end
  end

  @type zipped :: [{any,any}, ...]

  @spec unzip_and_get_elem(zipped, any)
    :: any
  def unzip_and_get_elem(zipped, e) do
    zipped
    |> Enum.unzip
    |> elem(e)
  end

  def evaluate_l2_template(
    adjacencies,
    switches,
    template,
    timestamp
  ) do
    EEx.eval_string template,
      [ timestamp: timestamp,
        switches: switches,
        edges: adjacencies,
      ]
  end

  defp router_to_node(router) do
    node_id = NetAddr.address router.polladdr

    router
    |> trim_domain_from_device_sysname
    |> Map.put(:id, node_id)
  end

  def evaluate_l3_template(incidences, routers, template) do
    current_datetime_utc = "#{DateTime.utc_now}"

    evaluate_l3_template(
      incidences,
      routers,
      template,
      current_datetime_utc
    )
  end

  def evaluate_l3_template(
    incidences,
    routers,
    template,
    timestamp
  ) do
    nodes =
      routers
      |> Enum.map(&router_to_node/1)
      |> Enum.sort_by(& &1.id)

    edges =
      incidences
      |> Enum.map(fn {_, subnet} -> subnet end)
      |> Enum.sort
      |> Enum.map(fn
        <<_::binary>> = subnet ->
          subnet

        subnet ->
          NetAddr.prefix subnet
      end)
      |> Enum.dedup

    EEx.eval_string template,
      [ timestamp: timestamp,
        routers: nodes,
        edges: edges,
        incidences: incidences,
      ]
  end
end
