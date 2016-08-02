# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.Querier do
  @moduledoc """
  A behaviour for querier implementations.
  """
  @type query_object :: :addresses | :arp_cache | :fdb | :routes | :sysname

  @callback query(object :: query_object, target :: NetAddr.t) :: [NetAddr.t]
end
