# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Discover.L3Test do
  use ExUnit.Case
  doctest Giraphe.Discover.L3

  import Giraphe.Discover.L3

  use NetAddr

  alias Giraphe.Router

  test "Returns list of routers and routes" do
    expected_routers =
      [ %Router{
          name: "192.0.2.3",
          polladdr: ~p(192.0.2.3/31),
          addresses: [
            ~p(192.0.2.3/31),
            ~p(192.0.2.8/31),
          ],
          routes: [
            {    ~p(192.0.2.2/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.4/31), ~p(192.0.2.2)},
            {    ~p(192.0.2.6/31), ~p(192.0.2.2)},
            {    ~p(192.0.2.8/31), ~p(0.0.0.0)},
            {   ~p(192.0.2.10/31), ~p(192.0.2.2)},
            {   ~p(192.0.2.12/30), ~p(192.0.2.9)},
            { ~p(198.51.100.0/29), ~p(192.0.2.2)},
            { ~p(198.51.100.8/29), ~p(192.0.2.2)},
            {~p(198.51.100.16/29), ~p(192.0.2.2)},
            {~p(198.51.100.24/29), ~p(192.0.2.2)},
            {~p(198.51.100.32/29), ~p(192.0.2.2)},
            {~p(198.51.100.40/29), ~p(192.0.2.9)},
          ],
        },
        %Router{
          name: "192.0.2.7",
          polladdr: ~p(192.0.2.7/31),
          addresses: [
            ~p(192.0.2.7/31),
            ~p(192.0.2.10/31),
            ~p(198.51.100.25/29),
            ~p(198.51.100.33/29),
          ],
          routes: [
            {    ~p(192.0.2.2/31), ~p(192.0.2.6)},
            {    ~p(192.0.2.4/31), ~p(192.0.2.6)},
            {    ~p(192.0.2.6/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.8/31), ~p(192.0.2.6)},
            {   ~p(192.0.2.10/31), ~p(0.0.0.0)},
            {   ~p(192.0.2.12/30), ~p(192.0.2.6)},
            { ~p(198.51.100.0/29), ~p(192.0.2.6)},
            { ~p(198.51.100.8/29), ~p(192.0.2.6)},
            {~p(198.51.100.16/29), ~p(192.0.2.6)},
            {~p(198.51.100.24/29), ~p(0.0.0.0)},
            {~p(198.51.100.32/29), ~p(0.0.0.0)},
            {~p(198.51.100.40/29), ~p(192.0.2.6)},
          ],
        },
        %Router{
          name: "192.0.2.9",
          polladdr: ~p(192.0.2.9/31),
          addresses: [
            ~p(192.0.2.5/31),
            ~p(192.0.2.9/31),
            ~p(192.0.2.11/31),
            ~p(192.0.2.13/30),
          ],
          routes: [
            {    ~p(192.0.2.2/31), ~p(192.0.2.8)},
            {    ~p(192.0.2.4/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.6/31), ~p(192.0.2.8)},
            {    ~p(192.0.2.8/31), ~p(0.0.0.0)},
            {   ~p(192.0.2.10/31), ~p(0.0.0.0)},
            {   ~p(192.0.2.12/30), ~p(0.0.0.0)},
            { ~p(198.51.100.0/29), ~p(192.0.2.8)},
            { ~p(198.51.100.8/29), ~p(192.0.2.8)},
            {~p(198.51.100.16/29), ~p(192.0.2.8)},
            {~p(198.51.100.24/29), ~p(192.0.2.8)},
            {~p(198.51.100.32/29), ~p(192.0.2.8)},
            {~p(198.51.100.40/29), ~p(192.0.2.14)},
          ],
        },
        %Router{
          name: "192.0.2.14",
          polladdr: ~p(192.0.2.14/30),
          addresses: [
            ~p(192.0.2.14/30)
          ],
          routes: [
            {~p(192.0.2.12/30), ~p(0.0.0.0)},
          ]
        },
        %Router{
          name: "198.51.100.1",
          polladdr: ~p(198.51.100.1/29),
          addresses: [
            ~p(192.0.2.2/31),
            ~p(192.0.2.4/31),
            ~p(192.0.2.6/31),
            ~p(198.51.100.1/29),
            ~p(198.51.100.9/29),
            ~p(198.51.100.17/29),
          ],
          routes: [
            {    ~p(192.0.2.2/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.4/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.6/31), ~p(0.0.0.0)},
            {    ~p(192.0.2.8/31), ~p(192.0.2.3)},
            {   ~p(192.0.2.10/31), ~p(192.0.2.7)},
            {   ~p(192.0.2.12/30), ~p(192.0.2.3)},
            { ~p(198.51.100.0/29), ~p(0.0.0.0)},
            { ~p(198.51.100.8/29), ~p(0.0.0.0)},
            {~p(198.51.100.16/29), ~p(0.0.0.0)},
            {~p(198.51.100.24/29), ~p(192.0.2.7)},
            {~p(198.51.100.32/29), ~p(192.0.2.7)},
            {~p(198.51.100.40/29), ~p(192.0.2.3)},
          ],
        }
      ]

    routers =
      discover_routers [
        ~p(198.51.100.1),
        ~p(192.0.2.4),
        ~p(198.51.100.1/29),
      ]

    assert routers == expected_routers
  end

  test "Returns other list of routers and routes" do
    expected_routers =
      [ %Router{
          name: "203.0.113.1",
          polladdr: ~p(203.0.113.1/32),
          addresses: [~p(203.0.113.1/32)],
          routes: [
            {~p(0.0.0.0/0), ~p(203.0.113.16/32)},
            {~p(203.0.113.1/32), ~p(0.0.0.0/32)},
            {~p(203.0.113.2/32), ~p(203.0.113.2/32)},
            {~p(203.0.113.3/32), ~p(203.0.113.3/32)},
            {~p(203.0.113.4/32), ~p(203.0.113.3/32)},
            {~p(203.0.113.5/32), ~p(203.0.113.2/32)},
            {~p(203.0.113.5/32), ~p(203.0.113.3/32)},
            {~p(203.0.113.16/31), ~p(0.0.0.0/32)},
          ],
        },
        %Router{
          name: "203.0.113.2",
          polladdr: ~p(203.0.113.2/32),
          addresses: [~p(203.0.113.2/32)],
          routes: [
            {~p(0.0.0.0/0), ~p(203.0.113.1/32)},
            {~p(203.0.113.1/32), ~p(203.0.113.1/32)},
            {~p(203.0.113.2/32), ~p(0.0.0.0/32)},
            {~p(203.0.113.3/32), ~p(203.0.113.1/32)},
            {~p(203.0.113.4/32), ~p(203.0.113.4/32)},
            {~p(203.0.113.5/32), ~p(203.0.113.5/32)},
          ],
        },
        %Router{
          name: "203.0.113.3",
          polladdr: ~p(203.0.113.3/32),
          addresses: [~p(203.0.113.3/32)],
          routes: [
            {~p(0.0.0.0/0), ~p(203.0.113.1/32)},
            {~p(203.0.113.1/32), ~p(203.0.113.1/32)},
            {~p(203.0.113.2/32), ~p(203.0.113.1/32)},
            {~p(203.0.113.3/32), ~p(0.0.0.0/32)},
            {~p(203.0.113.4/32), ~p(203.0.113.4/32)},
            {~p(203.0.113.5/32), ~p(203.0.113.4/32)},
          ],
        },
        %Router{
          name: "203.0.113.4",
          polladdr: ~p(203.0.113.4/32),
          addresses: [~p(203.0.113.4/32)],
          routes: [
            {~p(0.0.0.0/0), ~p(203.0.113.3/32)},
            {~p(203.0.113.1/32), ~p(203.0.113.3/32)},
            {~p(203.0.113.2/32), ~p(203.0.113.2/32)},
            {~p(203.0.113.3/32), ~p(203.0.113.3/32)},
            {~p(203.0.113.4/32), ~p(0.0.0.0/32)},
            {~p(203.0.113.5/32), ~p(203.0.113.5/32)},
          ],
        },
        %Router{
          name: "203.0.113.5",
          polladdr: ~p(203.0.113.5/32),
          addresses: [~p(203.0.113.5/32)],
          routes: [
            {~p(0.0.0.0/0), ~p(203.0.113.2/32)},
            {~p(0.0.0.0/0), ~p(203.0.113.4/32)},
            {~p(203.0.113.1/32), ~p(203.0.113.2/32)},
            {~p(203.0.113.1/32), ~p(203.0.113.4/32)},
            {~p(203.0.113.2/32), ~p(203.0.113.2/32)},
            {~p(203.0.113.3/32), ~p(203.0.113.4/32)},
            {~p(203.0.113.4/32), ~p(203.0.113.4/32)},
            {~p(203.0.113.5/32), ~p(0.0.0.0/32)},
          ]
        },
        %Router{
          name: "203.0.113.16",
          polladdr: ~p(203.0.113.16/31),
          addresses: [~p(203.0.113.16/31)],
          routes: [
            {~p(203.0.113.16/31), ~p(0.0.0.0/32)},
          ],
        },
      ]

    routers = discover_routers [~p(203.0.113.1)]

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
      [ %Router{
          name: "203.0.113.6",
          polladdr: ~p(203.0.113.6/31),
          addresses: [
            ~p(203.0.113.6/31),
          ],
          routes: [
            {~p(203.0.113.6/31), ~p(0.0.0.0)},
          ],
        },
      ]

    routers =
      discover_routers [~p(203.0.113.6/31)]

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
      [ %Router{
          name: "203.0.113.7",
          polladdr: ~p(203.0.113.7/31),
          addresses: [
            ~p(203.0.113.7/31),
            ~p(203.0.113.8/31),
          ],
          routes: [
            {~p(203.0.113.6/31), ~p(0.0.0.0)},
            {~p(203.0.113.8/31), ~p(0.0.0.0)},
          ],
        },
      ]

    routers = discover_routers [~p(203.0.113.7)]

    assert routers == expected_routers
  end

  test "Router with bad NetAddrs in routes explodes" do
    # Route churn can cause next-hops to change,
    # which cause SNMP table column indices to change,
    # which `snmptable` interprets as missing values,
    # which it then replaces with '?',
    # which `ip/1` rejects, returning `{:error, :einval}`.
    # Later calls to `NetAddr` functions therefore raise.
    #
    assert_raise FunctionClauseError, fn ->
      discover_routers [~p(203.0.113.9)]
    end
  end

  test """
  When a nexthop does not respond to polling, if that
  nexthop is an address of a known router, do not create a
  new router for the nexthop but use the existing router,
  instead.
  """
  do
    expected_routers =
      [ %Router{
          name: "203.0.113.10",
          polladdr: ~p(203.0.113.10),
          addresses: [
            ~p(203.0.113.10),
            ~p(203.0.113.12/31),
          ],
          routes: [
            {~p(203.0.113.10), ~p(0.0.0.0)},
            {~p(203.0.113.11), ~p(203.0.113.13)},
            {~p(203.0.113.12/31), ~p(0.0.0.0)},
          ]
        },
        %Router{
          name: "203.0.113.11",
          polladdr: ~p(203.0.113.11),
          addresses: [
            ~p(203.0.113.11),
            ~p(203.0.113.13/31),
          ],
          routes: [
            {~p(203.0.113.10), ~p(203.0.113.12)},
            {~p(203.0.113.11), ~p(0.0.0.0)},
            {~p(203.0.113.12/31), ~p(0.0.0.0)},
          ]
        },
      ]

    routers =
      discover_routers [
        ~p(203.0.113.10),
        ~p(203.0.113.11),
      ]

    assert routers == expected_routers
  end

  test """
  Routes with localhost next-hops do not generate
  localhost targets. Their respective connected routes
  likewise do not create loops, and local/connected route
  pairs are aggregated into a single connected route with
  next-hop self (0.0.0.0).
  """
  do
    expected_routers =
      [ %Router{
          name: "203.0.113.14",
          polladdr: ~p(203.0.113.14/31),
          addresses: [
            ~p(203.0.113.14/31),
          ],
          routes: [
            {~p(203.0.113.14/31), ~p(0.0.0.0)},
          ]
        },
      ]

    routers = discover_routers [~p(203.0.113.14)]

    assert routers == expected_routers
  end

  test """
  Discovery does not return multiples of the same router

         21 24
        /     \
    ->20       25
      22       27
        \     /
         23 26
  """
  do
    expected_routers =
      [ %Router{
          name: "203.0.113.20",
          polladdr: ~p(203.0.113.20/31),
          addresses: [
            ~p(203.0.113.20/31),
            ~p(203.0.113.22/31),
          ],
          routes: [
            {~p(203.0.113.20/31), ~p(0.0.0.0)},
            {~p(203.0.113.22/31), ~p(0.0.0.0)},
            {~p(203.0.113.24/31), ~p(203.0.113.21)},
            {~p(203.0.113.26/31), ~p(203.0.113.23)},
          ]
        },
        %Router{
          name: "203.0.113.21",
          polladdr: ~p(203.0.113.21/31),
          addresses: [
            ~p(203.0.113.21/31),
            ~p(203.0.113.24/31),
          ],
          routes: [
            {~p(203.0.113.20/31), ~p(0.0.0.0)},
            {~p(203.0.113.22/31), ~p(203.0.113.20)},
            {~p(203.0.113.24/31), ~p(0.0.0.0)},
            {~p(203.0.113.26/31), ~p(203.0.113.25)},
          ]
        },
        %Router{
          name: "203.0.113.23",
          polladdr: ~p(203.0.113.23/31),
          addresses: [
            ~p(203.0.113.23/31),
            ~p(203.0.113.26/31),
          ],
          routes: [
            {~p(203.0.113.20/31), ~p(203.0.113.22)},
            {~p(203.0.113.22/31), ~p(0.0.0.0)},
            {~p(203.0.113.24/31), ~p(203.0.113.27)},
            {~p(203.0.113.26/31), ~p(0.0.0.0)},
          ]
        },
        %Router{
          name: "203.0.113.25",
          polladdr: ~p(203.0.113.25/31),
          addresses: [
            ~p(203.0.113.25/31),
            ~p(203.0.113.27/31),
          ],
          routes: [
            {~p(203.0.113.20/31), ~p(203.0.113.24)},
            {~p(203.0.113.22/31), ~p(203.0.113.26)},
            {~p(203.0.113.24/31), ~p(0.0.0.0)},
            {~p(203.0.113.26/31), ~p(0.0.0.0)},
          ]
        },
      ]

    routers = discover_routers [~p(203.0.113.20)]

    assert routers == expected_routers
  end
end
