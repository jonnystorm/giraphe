# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.DiscoveryTest do
  use ExUnit.Case
  doctest Giraphe.L3.Discovery

  import Giraphe.L3.Discovery

  test "Returns tuple of routers and routes" do
    expected_routers =
      [ %Giraphe.Router{name: "192.0.2.3", polladdr: NetAddr.ip("192.0.2.3"),
          addresses: [NetAddr.ip("192.0.2.3/31"), NetAddr.ip("192.0.2.8/31")],
          routes: [
            {    NetAddr.ip("192.0.2.2/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.4/31"), NetAddr.ip("192.0.2.2")},
            {    NetAddr.ip("192.0.2.6/31"), NetAddr.ip("192.0.2.2")},
            {    NetAddr.ip("192.0.2.8/31"), NetAddr.ip("0.0.0.0")},
            {   NetAddr.ip("192.0.2.10/31"), NetAddr.ip("192.0.2.2")},
            {   NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.9")},
            { NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.2")},
            { NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.2")},
            {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.2")},
            {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.2")},
            {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.2")},
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.9")}
          ]
        },
        %Giraphe.Router{name: "192.0.2.7", polladdr: NetAddr.ip("192.0.2.7"),
          addresses: [
            NetAddr.ip("192.0.2.7/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("198.51.100.25/29"),
            NetAddr.ip("198.51.100.33/29")
          ],
          routes: [
            {    NetAddr.ip("192.0.2.2/31"), NetAddr.ip("192.0.2.6")},
            {    NetAddr.ip("192.0.2.4/31"), NetAddr.ip("192.0.2.6")},
            {    NetAddr.ip("192.0.2.6/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.8/31"), NetAddr.ip("192.0.2.6")},
            {   NetAddr.ip("192.0.2.10/31"), NetAddr.ip("0.0.0.0")},
            {   NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.6")},
            { NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.6")},
            { NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.6")},
            {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.6")},
            {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.6")}
          ]
        },
        %Giraphe.Router{name: "192.0.2.9", polladdr: NetAddr.ip("192.0.2.9"),
          addresses: [
            NetAddr.ip("192.0.2.13/30"),
            NetAddr.ip("192.0.2.9/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("192.0.2.5/31")
          ],
          routes: [
            {    NetAddr.ip("192.0.2.2/31"), NetAddr.ip("192.0.2.8")},
            {    NetAddr.ip("192.0.2.4/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.6/31"), NetAddr.ip("192.0.2.8")},
            {    NetAddr.ip("192.0.2.8/31"), NetAddr.ip("0.0.0.0")},
            {   NetAddr.ip("192.0.2.10/31"), NetAddr.ip("0.0.0.0")},
            {   NetAddr.ip("192.0.2.12/30"), NetAddr.ip("0.0.0.0")},
            { NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.8")},
            { NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.8")},
            {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.8")},
            {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.8")},
            {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.8")},
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.14")}
          ]
        },
        %Giraphe.Router{name: "192.0.2.14", polladdr: NetAddr.ip("192.0.2.14"),
          addresses: [NetAddr.ip("192.0.2.14/30")],
          routes: []
        },
        %Giraphe.Router{name: "198.51.100.1", polladdr: NetAddr.ip("198.51.100.1"),
          addresses: [
            NetAddr.ip("192.0.2.2/31"),
            NetAddr.ip("192.0.2.4/31"),
            NetAddr.ip("192.0.2.6/31"),
            NetAddr.ip("198.51.100.1/29"),
            NetAddr.ip("198.51.100.9/29"),
            NetAddr.ip("198.51.100.17/29")
          ],
          routes: [
            {    NetAddr.ip("192.0.2.2/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.4/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.6/31"), NetAddr.ip("0.0.0.0")},
            {    NetAddr.ip("192.0.2.8/31"), NetAddr.ip("192.0.2.3")},
            {   NetAddr.ip("192.0.2.10/31"), NetAddr.ip("192.0.2.7")},
            {   NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.3")},
            { NetAddr.ip("198.51.100.0/29"), NetAddr.ip("0.0.0.0")},
            { NetAddr.ip("198.51.100.8/29"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.7")},
            {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.7")},
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.3")}
          ]
        }
      ]

    routers = discover ["198.51.100.1"]

    assert routers == expected_routers
  end
end
