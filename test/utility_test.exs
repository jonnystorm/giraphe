# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
