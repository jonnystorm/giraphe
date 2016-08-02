# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L3.DotTest do
  use ExUnit.Case
  doctest Giraphe.L3.Dot

  import Giraphe.L3.Dot

  test "Generates dot from routers" do
    routers =
      [ %Giraphe.Router{name: "192.0.2.3", polladdr: NetAddr.ip("192.0.2.3"),
          addresses: [
            NetAddr.ip("192.0.2.3/31"),
            NetAddr.ip("192.0.2.8/31")
          ]
        },
        %Giraphe.Router{name: "192.0.2.7", polladdr: NetAddr.ip("192.0.2.7"),
          addresses: [
            NetAddr.ip("192.0.2.7/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("198.51.100.25/29"),
            NetAddr.ip("198.51.100.33/29")
          ]
        },
        %Giraphe.Router{name: "192.0.2.9", polladdr: NetAddr.ip("192.0.2.9"),
          addresses: [
            NetAddr.ip("192.0.2.13/30"),
            NetAddr.ip("192.0.2.9/31"),
            NetAddr.ip("192.0.2.10/31"),
            NetAddr.ip("192.0.2.5/31")
          ]
        },
        %Giraphe.Router{name: "192.0.2.14", polladdr: NetAddr.ip("192.0.2.14"),
          addresses: [NetAddr.ip("192.0.2.14/30")]
        },
        %Giraphe.Router{name: "198.51.100.1", polladdr: NetAddr.ip("198.51.100.1"),
          addresses: [
            NetAddr.ip("192.0.2.2/31"),
            NetAddr.ip("192.0.2.4/31"),
            NetAddr.ip("192.0.2.6/31"),
            NetAddr.ip("198.51.100.1/29"),
            NetAddr.ip("198.51.100.9/29"),
            NetAddr.ip("198.51.100.17/29")
          ]
        }
      ]

    assert generate_graph_from_routers(routers, "1970-01-01 00:00:00Z") ==
"""
graph G {
  graph [
    overlap=false
    label="1970-01-01 00:00:00Z"
    fontname="sans bold"
    labelloc=t
    labeljust=left
    size=15
  ];

  node [
    style=filled
    penwidth=2
    colorscheme=purples7
    color=7
    fontname="sans bold"
    fontsize=10
    fontcolor=7
  ];

  edge [
    len=1
    penwidth=2
    colorscheme=purples7
    color=7
    labelfontname="sans bold"
    labelfontsize=8
    labelfontcolor=7
  ];

  // Routers

  "192.0.2.14" [label="192.0.2.14" shape=circle fillcolor=2 width=3.5];
  "192.0.2.3" [label="192.0.2.3" shape=circle fillcolor=2 width=3.5];
  "192.0.2.7" [label="192.0.2.7" shape=circle fillcolor=2 width=3.5];
  "192.0.2.9" [label="192.0.2.9" shape=circle fillcolor=2 width=3.5];
  "198.51.100.1" [label="198.51.100.1" shape=circle fillcolor=2 width=3.5];


  // Subnets

  "192.0.2.2/31" [fillcolor=1 shape=rect style="filled, rounded" width=4];
  "192.0.2.4/31" [fillcolor=1 shape=rect style="filled, rounded" width=4];
  "192.0.2.6/31" [fillcolor=1 shape=rect style="filled, rounded" width=4];
  "192.0.2.8/31" [fillcolor=1 shape=rect style="filled, rounded" width=4];
  "192.0.2.10/31" [fillcolor=1 shape=rect style="filled, rounded" width=4];
  "192.0.2.12/30" [fillcolor=1 shape=rect style="filled, rounded" width=4];


  // Edges

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
end
