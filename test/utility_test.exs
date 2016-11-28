# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.UtilityTest do
  use ExUnit.Case

  import Giraphe.Utility

  test "Trims the domain from an FQDN name in a device" do
    device = %{name: "R1.test.net", polladdr: NetAddr.ip("192.0.2.1")}

    assert trim_domain_from_device_sysname(device) == %{device | name: "R1"}
  end

  test "Terminates recursive route lookup in presence of loop" do
    routes = [{NetAddr.ip("192.0.2.0/30"), NetAddr.ip("192.0.2.1")}]
    address = NetAddr.ip("192.0.2.1")

    assert lookup_route_recursive(routes, address) == nil
  end
end
