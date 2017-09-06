# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Discover.L3Test do
  use ExUnit.Case
  doctest Giraphe.Discover.L3

  import Giraphe.Discover.L3

  test "Returns list of routers and routes" do
    expected_routers =
      [ %Giraphe.Router{
          name: "192.0.2.3",
          polladdr: NetAddr.ip("192.0.2.3/31"),
          addresses: [
            NetAddr.ip("192.0.2.3/31"),
            NetAddr.ip("192.0.2.8/31"),
          ],
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
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.9")},
          ],
        },
        %Giraphe.Router{
          name: "192.0.2.7",
          polladdr: NetAddr.ip("192.0.2.7/31"),
          addresses: [
            NetAddr.ip("192.0.2.7/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("198.51.100.25/29"),
            NetAddr.ip("198.51.100.33/29"),
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
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.6")},
          ],
        },
        %Giraphe.Router{
          name: "192.0.2.9",
          polladdr: NetAddr.ip("192.0.2.9/31"),
          addresses: [
            NetAddr.ip("192.0.2.5/31"),
            NetAddr.ip("192.0.2.9/31"),
            NetAddr.ip("192.0.2.11/31"),
            NetAddr.ip("192.0.2.13/30"),
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
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.14")},
          ],
        },
        %Giraphe.Router{
          name: "192.0.2.14",
          polladdr: NetAddr.ip("192.0.2.14/30"),
          addresses: [
            NetAddr.ip("192.0.2.14/30")
          ],
          routes: [
            {NetAddr.ip("192.0.2.12/30"), NetAddr.ip("0.0.0.0")},
          ]
        },
        %Giraphe.Router{
          name: "198.51.100.1",
          polladdr: NetAddr.ip("198.51.100.1/29"),
          addresses: [
            NetAddr.ip("192.0.2.2/31"),
            NetAddr.ip("192.0.2.4/31"),
            NetAddr.ip("192.0.2.6/31"),
            NetAddr.ip("198.51.100.1/29"),
            NetAddr.ip("198.51.100.9/29"),
            NetAddr.ip("198.51.100.17/29"),
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
            {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.3")},
          ],
        }
      ]

    routers =
      discover_routers [
        NetAddr.ip("198.51.100.1"),
        NetAddr.ip("192.0.2.4"),
        NetAddr.ip("198.51.100.1/29"),
      ]

    assert routers == expected_routers
  end

  test "Returns other list of routers and routes" do
    expected_routers =
      [ %Giraphe.Router{
          name: "203.0.113.1",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 16>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 16>>, length: 31},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "203.0.113.2",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "203.0.113.3",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "203.0.113.4",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "203.0.113.5",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 1>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 3>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32},
              %NetAddr.IPv4{address: <<203, 0, 113, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<203, 0, 113, 5>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
          ]
        },
        %Giraphe.Router{
          name: "203.0.113.16",
          polladdr: %NetAddr.IPv4{address: <<203, 0, 113, 16>>, length: 31},
          addresses: [
            %NetAddr.IPv4{address: <<203, 0, 113, 16>>, length: 31}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<203, 0, 113, 16>>, length: 31},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
          ],
        },
      ]

    routers = discover_routers [NetAddr.ip("203.0.113.1")]

    assert routers == expected_routers
  end

  test """
    Router has connected route for polling address when no
    SNMP route entries exist
  """ do
    # The router at the given polling address must at least
    # have a connected route for the subnet on which the
    # polling address resides. Therefore, we return a router
    # with the connected route as its only route.
    #
    expected_routers =
      [ %Giraphe.Router{
          name: "203.0.113.6",
          polladdr: NetAddr.ip("203.0.113.6/31"),
          addresses: [
            NetAddr.ip("203.0.113.6/31"),
          ],
          routes: [
            {NetAddr.ip("203.0.113.6/31"), NetAddr.ip("0.0.0.0")},
          ],
        },
      ]

    routers =
      discover_routers [NetAddr.ip("203.0.113.6/31")]

    assert routers == expected_routers
  end

  test """
    Router with no SNMP route entries has connected routes
    for all addresses
  """ do
    # The router with the given addresses must at least
    # have connected routes for the subnets on which the
    # addresses respectively reside. Therefore, return a
    # router with the connected routes as its only routes.
    #
    expected_routers =
      [ %Giraphe.Router{
          name: "203.0.113.7",
          polladdr: NetAddr.ip("203.0.113.7/31"),
          addresses: [
            NetAddr.ip("203.0.113.7/31"),
            NetAddr.ip("203.0.113.8/31"),
          ],
          routes: [
            {NetAddr.ip("203.0.113.6/31"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("203.0.113.8/31"), NetAddr.ip("0.0.0.0")},
          ],
        },
      ]

    routers = discover_routers [NetAddr.ip("203.0.113.7")]

    assert routers == expected_routers
  end

  test "Router with bad NetAddrs in routes explodes" do
    # Route churn can cause next-hops to change, which
    # causes SNMP table column indices to change, which
    # `snmptable` interprets as missing values, which
    # it then replaces with '?', which
    # `NetAddr.ip/1` rejects, returning `{:error, :einval}`.
    # Later calls to `NetAddr` functions therefore raise.
    #
    assert_raise Protocol.UndefinedError, fn ->
      discover_routers [NetAddr.ip("203.0.113.9")]
    end
  end

  test "When a nexthop does not respond to polling, if that
        nexthop is an address of a known router, do not
        create a new router for the nexthop but use the
        existing router, instead."
  do
    expected_routers =
      [ %Giraphe.Router{
          name: "203.0.113.10",
          polladdr: NetAddr.ip("203.0.113.10"),
          addresses: [
            NetAddr.ip("203.0.113.10"),
            NetAddr.ip("203.0.113.12/31"),
          ],
          routes: [
            {NetAddr.ip("203.0.113.10"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("203.0.113.11"), NetAddr.ip("203.0.113.13")},
            {NetAddr.ip("203.0.113.12/31"), NetAddr.ip("0.0.0.0")},
          ]
        },
        %Giraphe.Router{
          name: "203.0.113.11",
          polladdr: NetAddr.ip("203.0.113.11"),
          addresses: [
            NetAddr.ip("203.0.113.11"),
            NetAddr.ip("203.0.113.13/31"),
          ],
          routes: [
            {NetAddr.ip("203.0.113.10"), NetAddr.ip("203.0.113.12")},
            {NetAddr.ip("203.0.113.11"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("203.0.113.12/31"), NetAddr.ip("0.0.0.0")},
          ]
        },
      ]

    routers =
      discover_routers [
        NetAddr.ip("203.0.113.10"),
        NetAddr.ip("203.0.113.11"),
      ]

    assert routers == expected_routers
  end

  test """
    Routes with localhost next-hops do not generate
    localhost targets. Their respective connected routes
    likewise do not create loops, and local/connected route
    pairs are aggregated into a single connected route with
    next-hop self (0.0.0.0).
  """ do
    expected_routers =
      [ %Giraphe.Router{
          name: "203.0.113.14",
          polladdr: NetAddr.ip("203.0.113.14/31"),
          addresses: [
            NetAddr.ip("203.0.113.14/31"),
          ],
          routes: [
            {NetAddr.ip("203.0.113.14/31"), NetAddr.ip("0.0.0.0")},
          ]
        },
      ]

    routers = discover_routers [NetAddr.ip("203.0.113.14")]

    assert routers == expected_routers
  end
end
