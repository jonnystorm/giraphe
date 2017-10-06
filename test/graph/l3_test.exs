# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Graph.L3Test do
  use ExUnit.Case

  import Giraphe.Graph.L3
  import NetAddr, only: [ip: 1]

  alias Giraphe.Router

  @test_template    "priv/templates/l3_test_graph.dot.eex"
  @dot_template     "priv/templates/l3_graph.dot.eex"
  @graphml_template "priv/templates/l3_graph.graphml.eex"

  defp get_test_network1 do
    [ %Router{
        name: "192.0.2.3",
        polladdr: ip("192.0.2.3"),
        addresses: [
          ip("192.0.2.3/31"),
          ip("192.0.2.8/31"),
        ],
        routes: [
          {ip("192.0.2.2/31"), ip("0.0.0.0")},
          {ip("192.0.2.4/31"), ip("192.0.2.2")},
          {ip("192.0.2.6/31"), ip("192.0.2.2")},
          {ip("192.0.2.8/31"), ip("0.0.0.0")},
          {ip("192.0.2.10/31"), ip("192.0.2.2")},
          {ip("192.0.2.12/30"), ip("192.0.2.9")},
          {ip("198.51.100.0/29"), ip("192.0.2.2")},
          {ip("198.51.100.8/29"), ip("192.0.2.2")},
          {ip("198.51.100.16/29"), ip("192.0.2.2")},
          {ip("198.51.100.24/29"), ip("192.0.2.2")},
          {ip("198.51.100.32/29"), ip("192.0.2.2")},
          {ip("198.51.100.40/29"), ip("192.0.2.9")},
        ],
      },
      %Router{
        name: "192.0.2.7",
        polladdr: ip("192.0.2.7"),
        addresses: [
          ip("192.0.2.7/31"),
          ip("192.0.2.10/31"),
          ip("198.51.100.25/29"),
          ip("198.51.100.33/29"),
        ],
        routes: [
          {ip("192.0.2.2/31"), ip("192.0.2.6")},
          {ip("192.0.2.4/31"), ip("192.0.2.6")},
          {ip("192.0.2.6/31"), ip("0.0.0.0")},
          {ip("192.0.2.8/31"), ip("192.0.2.6")},
          {ip("192.0.2.10/31"), ip("0.0.0.0")},
          {ip("192.0.2.12/30"), ip("192.0.2.6")},
          {ip("198.51.100.0/29"), ip("192.0.2.6")},
          {ip("198.51.100.8/29"), ip("192.0.2.6")},
          {ip("198.51.100.16/29"), ip("192.0.2.6")},
          {ip("198.51.100.24/29"), ip("0.0.0.0")},
          {ip("198.51.100.32/29"), ip("0.0.0.0")},
          {ip("198.51.100.40/29"), ip("192.0.2.6")},
        ],
      },
      %Router{
        name: "192.0.2.9",
        polladdr: ip("192.0.2.9"),
        addresses: [
          ip("192.0.2.5/31"),
          ip("192.0.2.9/31"),
          ip("192.0.2.11/31"),
          ip("192.0.2.13/30"),
        ],
        routes: [
          {ip("192.0.2.2/31"), ip("192.0.2.8")},
          {ip("192.0.2.4/31"), ip("0.0.0.0")},
          {ip("192.0.2.6/31"), ip("192.0.2.8")},
          {ip("192.0.2.8/31"), ip("0.0.0.0")},
          {ip("192.0.2.10/31"), ip("0.0.0.0")},
          {ip("192.0.2.12/30"), ip("0.0.0.0")},
          {ip("198.51.100.0/29"), ip("192.0.2.8")},
          {ip("198.51.100.8/29"), ip("192.0.2.8")},
          {ip("198.51.100.16/29"), ip("192.0.2.8")},
          {ip("198.51.100.24/29"), ip("192.0.2.8")},
          {ip("198.51.100.32/29"), ip("192.0.2.8")},
          {ip("198.51.100.40/29"), ip("192.0.2.14")},
        ],
      },
      %Router{
        name: "192.0.2.14",
        polladdr: ip("192.0.2.14"),
        addresses: [
          ip("192.0.2.14/30")
        ],
        routes: [
          {ip("192.0.2.14/30"), ip("0.0.0.0")}
        ],
      },
      %Router{
        name: "198.51.100.1",
        polladdr: ip("198.51.100.1"),
        addresses: [
          ip("192.0.2.2/31"),
          ip("192.0.2.4/31"),
          ip("192.0.2.6/31"),
          ip("198.51.100.1/29"),
          ip("198.51.100.9/29"),
          ip("198.51.100.17/29"),
        ],
        routes: [
          {ip("192.0.2.2/31"), ip("0.0.0.0")},
          {ip("192.0.2.4/31"), ip("0.0.0.0")},
          {ip("192.0.2.6/31"), ip("0.0.0.0")},
          {ip("192.0.2.8/31"), ip("192.0.2.3")},
          {ip("192.0.2.10/31"), ip("192.0.2.7")},
          {ip("192.0.2.12/30"), ip("192.0.2.3")},
          {ip("198.51.100.0/29"), ip("0.0.0.0")},
          {ip("198.51.100.8/29"), ip("0.0.0.0")},
          {ip("198.51.100.16/29"), ip("0.0.0.0")},
          {ip("198.51.100.24/29"), ip("192.0.2.7")},
          {ip("198.51.100.32/29"), ip("192.0.2.7")},
          {ip("198.51.100.40/29"), ip("192.0.2.3")},
        ],
      },
    ]
  end

  test "Generates dot from routers" do
    routers = get_test_network1()
    timestamp = "1970-01-01 00:00:00Z"
    expected =
      File.read!("test/fixtures/example_l3_graph.dot")

    template  = File.read! @dot_template
    dot = graph_devices(routers, timestamp, template)

    assert dot == expected
  end

  test "Generates GraphML from routers" do
    routers = get_test_network1()
    timestamp = "1970-01-01 00:00:00Z"
    expected =
      File.read!("test/fixtures/example_l3_graph.graphml")

    template  = File.read! @graphml_template
    graphml = graph_devices(routers, timestamp, template)

    assert graphml == expected
  end

  test "Generates dot from other routers" do
    routers =
      [ %Router{
          name: "192.0.2.2",
          polladdr: ip("192.0.2.2/31"),
          addresses: [ip("192.0.2.2/31")],
          routes: [
            {ip("192.0.2.2/31"), ip("0.0.0.0/32")},
          ],
        },
        %Router{
          name: "R1",
          polladdr: ip("198.51.100.1/32"),
          addresses: [
            ip("192.0.2.3/31"),
            ip("198.51.100.1/32"),
          ],
          routes: [
            {ip("0.0.0.0/0"), ip("192.0.2.2/32")},
            {ip("192.0.2.2/31"), ip("0.0.0.0/32")},
            {ip("198.51.100.1/32"), ip("0.0.0.0/32")},
            {ip("198.51.100.2/32"), ip("198.51.100.2/32")},
            {ip("198.51.100.3/32"), ip("198.51.100.3/32")},
            {ip("198.51.100.4/32"), ip("198.51.100.3/32")},
            {ip("198.51.100.5/32"), ip("198.51.100.2/32")},
            {ip("198.51.100.5/32"), ip("198.51.100.3/32")},
          ],
        },
        %Router{
          name: "R2",
          polladdr: ip("198.51.100.2/32"),
          addresses: [ip("198.51.100.2/32")],
          routes: [
            {ip("0.0.0.0/0"), ip("198.51.100.1/32")},
            {ip("198.51.100.1/32"), ip("198.51.100.1/32")},
            {ip("198.51.100.2/32"), ip("0.0.0.0/32")},
            {ip("198.51.100.3/32"), ip("198.51.100.1/32")},
            {ip("198.51.100.4/32"), ip("198.51.100.4/32")},
            {ip("198.51.100.5/32"), ip("198.51.100.5/32")},
          ],
        },
        %Router{
          name: "R3",
          polladdr: ip("198.51.100.3/32"),
          addresses: [ip("198.51.100.3/32")],
          routes: [
            {ip("0.0.0.0/0"), ip("198.51.100.1/32")},
            {ip("198.51.100.1/32"), ip("198.51.100.1/32")},
            {ip("198.51.100.2/32"), ip("198.51.100.1/32")},
            {ip("198.51.100.3/32"), ip("0.0.0.0/32")},
            {ip("198.51.100.4/32"), ip("198.51.100.4/32")},
            {ip("198.51.100.5/32"), ip("198.51.100.4/32")},
          ],
        },
        %Router{
          name: "R4",
          polladdr: ip("198.51.100.4/32"),
          addresses: [ip("198.51.100.4/32")],
          routes: [
            {ip("0.0.0.0/0"), ip("198.51.100.3/32")},
            {ip("198.51.100.1/32"), ip("198.51.100.3/32")},
            {ip("198.51.100.2/32"), ip("198.51.100.2/32")},
            {ip("198.51.100.3/32"), ip("198.51.100.3/32")},
            {ip("198.51.100.4/32"), ip("0.0.0.0/32")},
            {ip("198.51.100.5/32"), ip("198.51.100.5/32")},
          ],
        },
        %Router{
          name: "R5",
          polladdr: ip("198.51.100.5/32"),
          addresses: [ip("198.51.100.5/32")],
          routes: [
            {ip("0.0.0.0/0"), ip("198.51.100.2/32")},
            {ip("0.0.0.0/0"), ip("198.51.100.4/32")},
            {ip("198.51.100.1/32"), ip("198.51.100.2/32")},
            {ip("198.51.100.1/32"), ip("198.51.100.4/32")},
            {ip("198.51.100.2/32"), ip("198.51.100.2/32")},
            {ip("198.51.100.3/32"), ip("198.51.100.4/32")},
            {ip("198.51.100.4/32"), ip("198.51.100.4/32")},
            {ip("198.51.100.5/32"), ip("0.0.0.0/32")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"
    template  = File.read! @test_template

    assert graph_devices(routers, timestamp, template) ==
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

  test """
    Outputs no edge when a router is assigned multiple
    addresses (aliases, secondaries) on the same subnet but
    has no adjacent routers on that subnet
  """ do
    routers =
      [ %Router{
          name: "192.0.2.1",
          polladdr: ip("192.0.2.1/24"),
          addresses: [
            ip("192.0.2.1/24"),
            ip("192.0.2.2/24"),
          ],
          routes: [
            {ip("192.0.2.0/24"), ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"
    template  = File.read! @test_template

    assert graph_devices(routers, timestamp, template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];



      }
      """
  end

  test "Outputs router label without domain name" do
    routers =
      [ %Router{
          name: "R1.test.net",
          polladdr: ip("192.0.2.1/24"),
          addresses: [
            ip("192.0.2.1/24"),
          ],
          routes: [],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"
    template  = File.read! @test_template

    assert graph_devices(routers, timestamp, template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="R1"];



      }
      """
  end

  test """
    (VRF) Addresses without corresponding non-summary
    connected routes do not produce incidences
  """ do
    routers =
      [ %Router{
          name: "192.0.2.1",
          polladdr: ip("192.0.2.1/24"),
          addresses: [
            ip("192.0.2.1/24"),
            ip("198.51.100.2/31"),
          ],
          routes: [
            {ip("192.0.2.0/24"), ip("0.0.0.0")},
            {ip("203.0.113.0/24"), ip("198.51.100.3")},
          ],
        },
        %Router{
          name: "198.51.100.5",
          polladdr: ip("198.51.100.5/31"),
          addresses: [
            ip("192.0.2.0/24"),
            ip("198.51.100.4/31"),
            ip("203.0.113.1/24"),
          ],
          routes: [
            {ip("192.0.0.0/8"), ip("0.0.0.0")},
            {ip("192.0.2.0/24"), ip("198.51.100.4")},
            {ip("203.0.113.0/24"), ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"
    template  = File.read! @test_template

    assert graph_devices(routers, timestamp, template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];
        "198.51.100.5" [label="198.51.100.5"];



      }
      """
  end

  test """
    Router address that is not a next-hop for other routers
    does not produce incidences
  """ do
    routers =
      [ %Router{
          name: "192.0.2.1",
          polladdr: ip("192.0.2.1/24"),
          addresses: [
            ip("192.0.2.1/24"),
          ],
          routes: [
            {ip("192.0.2.0/24"), ip("0.0.0.0")},
          ],
        },
        %Router{
          name: "198.51.100.5",
          polladdr: ip("198.51.100.5/31"),
          addresses: [
            ip("192.0.2.2/24"),
          ],
          routes: [
            {ip("192.0.2.0/24"), ip("0.0.0.0")},
          ],
        },
      ]

    timestamp = "1970-01-01 00:00:00Z"
    template  = File.read! @test_template

    assert graph_devices(routers, timestamp, template) ==
      """
      graph G {
        label="#{timestamp}"

        "192.0.2.1" [label="192.0.2.1"];
        "198.51.100.5" [label="198.51.100.5"];



      }
      """
  end
end
