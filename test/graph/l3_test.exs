# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Graph.L3Test do
  use ExUnit.Case

  import Giraphe.Graph.L3

  @test_template    "priv/templates/l3_test_graph.dot.eex"
  @dot_template     "priv/templates/l3_graph.dot.eex"
  @graphml_template "priv/templates/l3_graph.graphml.eex"

  defp get_test_network1 do
    [ %Giraphe.Router{
        name: "192.0.2.3",
        polladdr: NetAddr.ip("192.0.2.3"),
        addresses: [
          NetAddr.ip("192.0.2.3/31"),
          NetAddr.ip("192.0.2.8/31"),
        ],
        routes: [
          {NetAddr.ip("192.0.2.2/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.4/31"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("192.0.2.6/31"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("192.0.2.8/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.10/31"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.9")},
          {NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.2")},
          {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.9")},
        ],
      },
      %Giraphe.Router{
        name: "192.0.2.7",
        polladdr: NetAddr.ip("192.0.2.7"),
        addresses: [
          NetAddr.ip("192.0.2.7/31"),
          NetAddr.ip("192.0.2.10/31"),
          NetAddr.ip("198.51.100.25/29"),
          NetAddr.ip("198.51.100.33/29"),
        ],
        routes: [
          {NetAddr.ip("192.0.2.2/31"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("192.0.2.4/31"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("192.0.2.6/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.8/31"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("192.0.2.10/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.6")},
          {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.6")},
        ],
      },
      %Giraphe.Router{
        name: "192.0.2.9",
        polladdr: NetAddr.ip("192.0.2.9"),
        addresses: [
          NetAddr.ip("192.0.2.5/31"),
          NetAddr.ip("192.0.2.9/31"),
          NetAddr.ip("192.0.2.11/31"),
          NetAddr.ip("192.0.2.13/30"),
        ],
        routes: [
          {NetAddr.ip("192.0.2.2/31"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("192.0.2.4/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.6/31"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("192.0.2.8/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.10/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.12/30"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.0/29"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("198.51.100.8/29"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.8")},
          {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.14")},
        ],
      },
      %Giraphe.Router{
        name: "192.0.2.14",
        polladdr: NetAddr.ip("192.0.2.14"),
        addresses: [
          NetAddr.ip("192.0.2.14/30")
        ],
        routes: [
          {NetAddr.ip("192.0.2.14/30"), NetAddr.ip("0.0.0.0")}
        ],
      },
      %Giraphe.Router{
        name: "198.51.100.1",
        polladdr: NetAddr.ip("198.51.100.1"),
        addresses: [
          NetAddr.ip("192.0.2.2/31"),
          NetAddr.ip("192.0.2.4/31"),
          NetAddr.ip("192.0.2.6/31"),
          NetAddr.ip("198.51.100.1/29"),
          NetAddr.ip("198.51.100.9/29"),
          NetAddr.ip("198.51.100.17/29"),
        ],
        routes: [
          {NetAddr.ip("192.0.2.2/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.4/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.6/31"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("192.0.2.8/31"), NetAddr.ip("192.0.2.3")},
          {NetAddr.ip("192.0.2.10/31"), NetAddr.ip("192.0.2.7")},
          {NetAddr.ip("192.0.2.12/30"), NetAddr.ip("192.0.2.3")},
          {NetAddr.ip("198.51.100.0/29"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.8/29"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.16/29"), NetAddr.ip("0.0.0.0")},
          {NetAddr.ip("198.51.100.24/29"), NetAddr.ip("192.0.2.7")},
          {NetAddr.ip("198.51.100.32/29"), NetAddr.ip("192.0.2.7")},
          {NetAddr.ip("198.51.100.40/29"), NetAddr.ip("192.0.2.3")},
        ],
      },
    ]
  end

  test "Generates dot from routers" do
    routers = get_test_network1()
    timestamp = "1970-01-01 00:00:00Z"
    expected = File.read!("test/fixtures/example_l3_graph.dot")

    assert graph_devices(routers, timestamp, @dot_template) == expected
  end

  test "Generates GraphML from routers" do
    routers = get_test_network1()
    timestamp = "1970-01-01 00:00:00Z"
    expected = File.read!("test/fixtures/example_l3_graph.graphml")

    assert graph_devices(routers, timestamp, @graphml_template) == expected
  end

  test "Generates dot from other routers" do
    routers =
      [ %Giraphe.Router{
          name: "192.0.2.2",
          polladdr: %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31},
          addresses: [
            %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31}
          ],
          routes: [
            { %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "R1",
          polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<192, 0, 2, 3>>, length: 31},
            %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<192, 0, 2, 2>>, length: 31},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "R2",
          polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
          ],
          routes: [
           { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
             %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
           },
           { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
             %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
           },
           { %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
             %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
           },
           { %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
             %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
           },
           { %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
             %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
           },
           { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
             %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}
           },
          ],
        },
        %Giraphe.Router{
          name: "R3",
          polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "R4",
          polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32}
            },
          ],
        },
        %Giraphe.Router{
          name: "R5",
          polladdr: %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
          addresses: [
            %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
          ],
          routes: [
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 0},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 1>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 2>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 3>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32},
              %NetAddr.IPv4{address: <<198, 51, 100, 4>>, length: 32}
            },
            { %NetAddr.IPv4{address: <<198, 51, 100, 5>>, length: 32},
              %NetAddr.IPv4{address: <<0, 0, 0, 0>>, length: 32}
            },
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @test_template) ==
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
      [ %Giraphe.Router{
          name: "192.0.2.1",
          polladdr: NetAddr.ip("192.0.2.1/24"),
          addresses: [
            NetAddr.ip("192.0.2.1/24"),
            NetAddr.ip("192.0.2.2/24"),
          ],
          routes: [
            {NetAddr.ip("192.0.2.0/24"), NetAddr.ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @test_template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];



      }
      """
  end

  test "Outputs router label without domain name" do
    routers =
      [ %Giraphe.Router{
          name: "R1.test.net",
          polladdr: NetAddr.ip("192.0.2.1/24"),
          addresses: [
            NetAddr.ip("192.0.2.1/24"),
          ],
          routes: [],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @test_template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="R1"];



      }
      """
  end

  test "(VRF) Addresses without corresponding non-summary connected routes do not induce incidences" do
    routers =
      [ %Giraphe.Router{
          name: "192.0.2.1",
          polladdr: NetAddr.ip("192.0.2.1/24"),
          addresses: [
            NetAddr.ip("192.0.2.1/24"),
            NetAddr.ip("198.51.100.2/31"),
          ],
          routes: [
            {NetAddr.ip("192.0.2.0/24"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("203.0.113.0/24"), NetAddr.ip("198.51.100.3")},
          ],
        },
        %Giraphe.Router{
          name: "198.51.100.5",
          polladdr: NetAddr.ip("198.51.100.5/31"),
          addresses: [
            NetAddr.ip("192.0.2.0/24"),
            NetAddr.ip("198.51.100.4/31"),
            NetAddr.ip("203.0.113.1/24"),
          ],
          routes: [
            {NetAddr.ip("192.0.0.0/8"), NetAddr.ip("0.0.0.0")},
            {NetAddr.ip("192.0.2.0/24"), NetAddr.ip("198.51.100.4")},
            {NetAddr.ip("203.0.113.0/24"), NetAddr.ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @test_template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];
        "198.51.100.5" [label="198.51.100.5"];



      }
      """
  end

  test "Router address that is not a next-hop for other routers does not induce incidences" do
    routers =
      [ %Giraphe.Router{
          name: "192.0.2.1",
          polladdr: NetAddr.ip("192.0.2.1/24"),
          addresses: [
            NetAddr.ip("192.0.2.1/24"),
          ],
          routes: [
            {NetAddr.ip("192.0.2.0/24"), NetAddr.ip("0.0.0.0")},
          ],
        },
        %Giraphe.Router{
          name: "198.51.100.5",
          polladdr: NetAddr.ip("198.51.100.5/31"),
          addresses: [
            NetAddr.ip("192.0.2.2/24"),
          ],
          routes: [
            {NetAddr.ip("192.0.2.0/24"), NetAddr.ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"

    assert graph_devices(routers, timestamp, @test_template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];
        "198.51.100.5" [label="198.51.100.5"];



      }
      """
  end
end
