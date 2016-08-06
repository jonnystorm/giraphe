# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Discover do
  @moduledoc """
  Common interface for discover modules.
  """

  def discover_l2(gateway_address, subnet) do
    Giraphe.Discover.L2.discover gateway_address, subnet
  end

  def discover_l3(targets) do
    Giraphe.Discover.L3.discover targets
  end
end
