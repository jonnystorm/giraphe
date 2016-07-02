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
      [ %Giraphe.Router{name: "192.0.2.3", polladdr: "192.0.2.3",
          addresses: [
            "192.0.2.3/31",
            "192.0.2.8/31"
          ]
        },
        %Giraphe.Router{name: "192.0.2.7", polladdr: "192.0.2.7",
          addresses: [
            "192.0.2.7/31",
            "192.0.2.10/31",
            "198.51.100.25/29",
            "198.51.100.33/29"
          ]
        },
        %Giraphe.Router{name: "192.0.2.9", polladdr: "192.0.2.9",
          addresses: [
            "192.0.2.13/30",
            "192.0.2.9/31",
            "192.0.2.10/31",
            "192.0.2.5/31"
          ]
        },
        %Giraphe.Router{name: "192.0.2.14", polladdr: "192.0.2.14",
          addresses: ["192.0.2.14/30"]
        },
        %Giraphe.Router{name: "198.51.100.1", polladdr: "198.51.100.1",
          addresses: [
            "192.0.2.2/31",
            "192.0.2.4/31",
            "192.0.2.6/31",
            "198.51.100.1/29",
            "198.51.100.9/29",
            "198.51.100.17/29"
          ]
        }
      ]

    assert graph_from_routers(routers) ==
"""
graph G {
  graph [
    outputorder=edgesfirst
    overlap=false
  ];

  node [
    style=filled
    fontname="sans bold"
    fontsize=12
    fontcolor=7
    penwidth=2
    colorscheme=blues7
    color=7
  ];

  edge [
    len=1
    penwidth=2
    colorscheme=blues7
    color=7
  ];

  // Routers

  "192.0.2.3" [label="192.0.2.3" shape=circle fillcolor=2 fixedsize=true width=1.5];

  "192.0.2.7" [label="192.0.2.7" shape=circle fillcolor=2 fixedsize=true width=1.5];

  "192.0.2.9" [label="192.0.2.9" shape=circle fillcolor=2 fixedsize=true width=1.5];

  "192.0.2.14" [label="192.0.2.14" shape=circle fillcolor=2 fixedsize=true width=1.5];

  "198.51.100.1" [label="198.51.100.1" shape=circle fillcolor=2 fixedsize=true width=1.5];


  // Subnets

  "192.0.2.2/31" [fillcolor=1];

  "192.0.2.4/31" [fillcolor=1];

  "192.0.2.6/31" [fillcolor=1];

  "192.0.2.8/31" [fillcolor=1];

  "192.0.2.10/31" [fillcolor=1];

  "192.0.2.12/30" [fillcolor=1];

  "198.51.100.0/29" [fillcolor=1];

  "198.51.100.8/29" [fillcolor=1];

  "198.51.100.16/29" [fillcolor=1];

  "198.51.100.24/29" [fillcolor=1];

  "198.51.100.32/29" [fillcolor=1];


  // Edges

  "192.0.2.3" -- "192.0.2.2/31";

  "192.0.2.3" -- "192.0.2.8/31";

  "192.0.2.7" -- "192.0.2.6/31";

  "192.0.2.7" -- "192.0.2.10/31";

  "192.0.2.7" -- "198.51.100.24/29";

  "192.0.2.7" -- "198.51.100.32/29";

  "192.0.2.9" -- "192.0.2.4/31";

  "192.0.2.9" -- "192.0.2.8/31";

  "192.0.2.9" -- "192.0.2.10/31";

  "192.0.2.9" -- "192.0.2.12/30";

  "192.0.2.14" -- "192.0.2.12/30";

  "198.51.100.1" -- "192.0.2.2/31";

  "198.51.100.1" -- "192.0.2.4/31";

  "198.51.100.1" -- "192.0.2.6/31";

  "198.51.100.1" -- "198.51.100.0/29";

  "198.51.100.1" -- "198.51.100.8/29";

  "198.51.100.1" -- "198.51.100.16/29";

}
"""
  end
end
