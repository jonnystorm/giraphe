# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Router do
  @moduledoc """
  Defines a struct for storing routes and router addresses.
  """

  defstruct name: nil, polladdr: nil, addresses: nil, routes: nil

  @type name        :: String.t
  @type netaddr     :: NetAddr.t
  @type destination :: netaddr
  @type next_hop    :: netaddr
  @type route       :: {destination, next_hop}

  @type t :: %Giraphe.Router{
         name: name,
     polladdr: netaddr,
    addresses: [netaddr],
       routes: [route]
  }
end

defimpl String.Chars, for: Giraphe.Router do
  import Kernel, except: [to_string: 1]

  def to_string(router) do
    addresses =
      router.addresses
        |> Enum.join(", ")

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
