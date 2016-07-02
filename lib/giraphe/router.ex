# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Router do
  defstruct name: nil, polladdr: nil, addresses: nil, routes: nil

  @type name        :: String.t
  @type netaddr     :: String.t
  @type destination :: String.t
  @type next_hop    :: String.t
  @type route       :: {destination, next_hop}

  @type t :: %Giraphe.Router{
         name: name,
     polladdr: netaddr,
    addresses: [netaddr],
       routes: [route]
  }
end
