# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Router do
  @moduledoc """
  Defines a struct for storing routes and router addresses.
  """

  defstruct [
    :name,
    :polladdr,
    :addresses,
    :routes,
  ]

  @type name        :: String.t
  @type netaddr     :: NetAddr.t
  @type destination :: netaddr
  @type next_hop    :: netaddr
  @type route       :: {destination, next_hop}

  @type t :: %__MODULE__{
         name: name,
     polladdr: netaddr,
    addresses: [netaddr],
       routes: [route]
  }

  alias Giraphe.Utility

  defp non_connected_routes(router) do
    Enum.filter router.routes,
      & !Utility.is_connected_route(&1)
  end

  def is_an_island?(router) do
    # A router that is an "island" knows only about itself.
    # Could also be called "solipsistic router" if you were
    # feeling glib.
    #
    non_connected_routes(router) == []
  end

  def is_not_an_island?(router),
    do: ! is_an_island?(router)

  def has_connected_route_for_address?(router, address) do
    router.routes
    |> Enum.reverse
    |> Utility.find_route_containing_address(address)
    |> Utility.is_connected_route
  end
end


defimpl String.Chars, for: Giraphe.Router do
  import Kernel, except: [to_string: 1]

  def to_string(router) do
    addresses = Enum.join(router.addresses, ", ")

    routes =
      router.routes
      |> Stream.map(fn {destination, next_hop} ->
        "#{destination} => #{next_hop}"
      end)
      |> Enum.join(",\n    ")

    "#{router.name}: #{router.polladdr} (#{addresses})
    #{routes}\n"
  end
end
