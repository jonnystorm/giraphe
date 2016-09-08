# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Graph.Dot.L3Test do
  use ExUnit.Case
  doctest Giraphe.Graph.Dot.L3

  import Giraphe.Graph.Dot.L3

  @template Giraphe.Graph.l3_graph_template

  test "Generates dot from routers" do
    routers =
      [ %Giraphe.Router{name: "192.0.2.3", polladdr: NetAddr.ip("192.0.2.3"),
          addresses: [
            NetAddr.ip("192.0.2.3/31"),
            NetAddr.ip("192.0.2.8/31")
          ],
          routes: []
        },
        %Giraphe.Router{name: "192.0.2.7", polladdr: NetAddr.ip("192.0.2.7"),
          addresses: [
            NetAddr.ip("192.0.2.7/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("198.51.100.25/29"),
            NetAddr.ip("198.51.100.33/29")
          ],
          routes: []
        },
        %Giraphe.Router{name: "192.0.2.9", polladdr: NetAddr.ip("192.0.2.9"),
          addresses: [
            NetAddr.ip("192.0.2.13/30"),
            NetAddr.ip("192.0.2.9/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("192.0.2.5/31")
          ],
          routes: []
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
          routes: []
        }
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.14" [label="192.0.2.14"];
        "192.0.2.3" [label="192.0.2.3"];
        "192.0.2.7" [label="192.0.2.7"];
        "192.0.2.9" [label="192.0.2.9"];
        "198.51.100.1" [label="198.51.100.1"];

        "192.0.2.2/31";
        "192.0.2.4/31";
        "192.0.2.6/31";
        "192.0.2.8/31";
        "192.0.2.10/31";
        "192.0.2.12/30";

        "192.0.2.14" -- "192.0.2.12/30";
        "192.0.2.3" -- "192.0.2.2/31";
        "192.0.2.3" -- "192.0.2.8/31";
        "192.0.2.7" -- "192.0.2.6/31";
        "192.0.2.7" -- "192.0.2.10/31";
        "192.0.2.9" -- "192.0.2.4/31";
        "192.0.2.9" -- "192.0.2.8/31";
        "192.0.2.9" -- "192.0.2.10/31";
        "192.0.2.9" -- "192.0.2.12/30";
        "198.51.100.1" -- "192.0.2.2/31";
        "198.51.100.1" -- "192.0.2.4/31";
        "198.51.100.1" -- "192.0.2.6/31";

      }
      """
  end

  test "Generates dot from other routers" do
    routers =
      [ %Giraphe.Router{name: "192.0.2.2", polladdr: %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31},
          addresses: [%NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31}],
          routes: [
           {%NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}}
          ]
        },
        %Giraphe.Router{name: "R1", polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<192, 0, 2, 3>>, length: 31},
            %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
          ],
          routes: [
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}}
          ]
        },
        %Giraphe.Router{name: "R2", polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
          addresses: [%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}],
          routes: [
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
           {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
           {%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}},
           {%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
           {%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
           {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}}
          ]
        },
        %Giraphe.Router{name: "R3", polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
          addresses: [%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}],
          routes: [
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}}
          ]
        },
        %Giraphe.Router{name: "R4", polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
          addresses: [%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}],
          routes: [
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}}
          ]
        },
        %Giraphe.Router{name: "R5", polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
          addresses: [%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}],
          routes: [
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}, %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}},
            {%NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}, %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}}
          ]
        }
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.2" [label="192.0.2.2"];
        "198.51.100.1" [label="R1"];
        "198.51.100.2" [label="R2"];
        "198.51.100.3" [label="R3"];
        "198.51.100.4" [label="R4"];
        "198.51.100.5" [label="R5"];

        "192.0.2.2/31";
        "198.51.100.1/32:198.51.100.2/32";
        "198.51.100.1/32:198.51.100.3/32";
        "198.51.100.2/32:198.51.100.4/32";
        "198.51.100.2/32:198.51.100.5/32";
        "198.51.100.3/32:198.51.100.4/32";
        "198.51.100.4/32:198.51.100.5/32";

        "192.0.2.2" -- "192.0.2.2/31";
        "198.51.100.1" -- "192.0.2.2/31";
        "198.51.100.1" -- "198.51.100.1/32:198.51.100.2/32";
        "198.51.100.1" -- "198.51.100.1/32:198.51.100.3/32";
        "198.51.100.2" -- "198.51.100.1/32:198.51.100.2/32";
        "198.51.100.2" -- "198.51.100.2/32:198.51.100.4/32";
        "198.51.100.2" -- "198.51.100.2/32:198.51.100.5/32";
        "198.51.100.3" -- "198.51.100.1/32:198.51.100.3/32";
        "198.51.100.3" -- "198.51.100.3/32:198.51.100.4/32";
        "198.51.100.4" -- "198.51.100.2/32:198.51.100.4/32";
        "198.51.100.4" -- "198.51.100.3/32:198.51.100.4/32";
        "198.51.100.4" -- "198.51.100.4/32:198.51.100.5/32";
        "198.51.100.5" -- "198.51.100.2/32:198.51.100.5/32";
        "198.51.100.5" -- "198.51.100.4/32:198.51.100.5/32";

      }
      """
  end

  test "Outputs no edge when a router is assigned multiple addresses (aliases)
        from the same subnet but has no neighbors on that subnet"
  do
    routers =
      [ %Giraphe.Router{name: "192.0.2.1", polladdr: NetAddr.ip("192.0.2.1/24"),
          addresses: [NetAddr.ip("192.0.2.1/24"), NetAddr.ip("192.0.2.2/24")], routes: []
        }
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];



      }
      """
  end
end
