# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.L2.DotTest do
  use ExUnit.Case
  doctest Giraphe.L2.Dot

  import Giraphe.L2.Dot

  test "Generates dot from switches" do
    switches =
      [ %Giraphe.Switch{name: "192.0.2.3", polladdr: NetAddr.ip("192.0.2.3"), physaddr: NetAddr.mac_48("00:00:00:00:00:03"), uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:07")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:10")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:20")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:30")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:40")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:50")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:51")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:52")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:53")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:54")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:55")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:56")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:57")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:58")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:59")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:60")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:70")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:80")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:90")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:00")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:02")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:03")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:04")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:05")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:06")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:07")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:08")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:09")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:10")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:20")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:30")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:40")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:50")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:60")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:70")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:80")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:90")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:02:00")}
          ]
        },
        %Giraphe.Switch{name: "192.0.2.7", polladdr: NetAddr.ip("192.0.2.7"), physaddr: NetAddr.mac_48("00:00:00:00:00:07"), uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:10")},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:20")},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:30")},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:40")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:50")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:51")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:52")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:53")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:54")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:55")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:56")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:57")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:58")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:59")},
            {"Gi1/6",  NetAddr.mac_48("00:00:00:00:00:60")},
            {"Gi1/7",  NetAddr.mac_48("00:00:00:00:00:70")},
            {"Gi1/8",  NetAddr.mac_48("00:00:00:00:00:80")},
            {"Gi1/9",  NetAddr.mac_48("00:00:00:00:00:90")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:00")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:01")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:02")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:03")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:04")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:05")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:06")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:07")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:08")},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:09")},
            {"Gi1/11", NetAddr.mac_48("00:00:00:00:01:10")},
            {"Gi1/12", NetAddr.mac_48("00:00:00:00:01:20")},
            {"Gi1/13", NetAddr.mac_48("00:00:00:00:01:30")},
            {"Gi1/14", NetAddr.mac_48("00:00:00:00:01:40")},
            {"Gi1/15", NetAddr.mac_48("00:00:00:00:01:50")},
            {"Gi1/16", NetAddr.mac_48("00:00:00:00:01:60")},
            {"Gi1/17", NetAddr.mac_48("00:00:00:00:01:70")},
            {"Gi1/18", NetAddr.mac_48("00:00:00:00:01:80")},
            {"Gi1/19", NetAddr.mac_48("00:00:00:00:01:90")},
            {"Gi1/20", NetAddr.mac_48("00:00:00:00:02:00")}
          ]
        },
        %Giraphe.Switch{name: "192.0.2.10", polladdr: NetAddr.ip("192.0.2.10"), physaddr: NetAddr.mac_48("00:00:00:00:00:10"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.20", polladdr: NetAddr.ip("192.0.2.20"), physaddr: NetAddr.mac_48("00:00:00:00:00:20"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.30", polladdr: NetAddr.ip("192.0.2.30"), physaddr: NetAddr.mac_48("00:00:00:00:00:30"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.40", polladdr: NetAddr.ip("192.0.2.40"), physaddr: NetAddr.mac_48("00:00:00:00:00:40"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.50", polladdr: NetAddr.ip("192.0.2.50"), physaddr: NetAddr.mac_48("00:00:00:00:00:50"), uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:51")},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:52")},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:53")},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:54")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:55")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:56")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:57")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:58")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:59")}
          ]
        },
        %Giraphe.Switch{name: "192.0.2.51", polladdr: NetAddr.ip("192.0.2.51"), physaddr: NetAddr.mac_48("00:00:00:00:00:51"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.52", polladdr: NetAddr.ip("192.0.2.52"), physaddr: NetAddr.mac_48("00:00:00:00:00:52"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.53", polladdr: NetAddr.ip("192.0.2.53"), physaddr: NetAddr.mac_48("00:00:00:00:00:53"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.54", polladdr: NetAddr.ip("192.0.2.54"), physaddr: NetAddr.mac_48("00:00:00:00:00:54"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.55", polladdr: NetAddr.ip("192.0.2.55"), physaddr: NetAddr.mac_48("00:00:00:00:00:55"), uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:56")},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:57")},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:58")},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:59")}
          ]
        },
        %Giraphe.Switch{name:  "192.0.2.56", polladdr: NetAddr.ip( "192.0.2.56"), physaddr: NetAddr.mac_48("00:00:00:00:00:56"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.57", polladdr: NetAddr.ip( "192.0.2.57"), physaddr: NetAddr.mac_48("00:00:00:00:00:57"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.58", polladdr: NetAddr.ip( "192.0.2.58"), physaddr: NetAddr.mac_48("00:00:00:00:00:58"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.59", polladdr: NetAddr.ip( "192.0.2.59"), physaddr: NetAddr.mac_48("00:00:00:00:00:59"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.60", polladdr: NetAddr.ip( "192.0.2.60"), physaddr: NetAddr.mac_48("00:00:00:00:00:60"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.70", polladdr: NetAddr.ip( "192.0.2.70"), physaddr: NetAddr.mac_48("00:00:00:00:00:70"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.80", polladdr: NetAddr.ip( "192.0.2.80"), physaddr: NetAddr.mac_48("00:00:00:00:00:80"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name:  "192.0.2.90", polladdr: NetAddr.ip( "192.0.2.90"), physaddr: NetAddr.mac_48("00:00:00:00:00:90"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.100", polladdr: NetAddr.ip("192.0.2.100"), physaddr: NetAddr.mac_48("00:00:00:00:01:00"), uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:01")},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:01:02")},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:01:03")},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:01:04")},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:01:05")},
            {"Gi1/6",  NetAddr.mac_48("00:00:00:00:01:06")},
            {"Gi1/7",  NetAddr.mac_48("00:00:00:00:01:07")},
            {"Gi1/8",  NetAddr.mac_48("00:00:00:00:01:08")},
            {"Gi1/9",  NetAddr.mac_48("00:00:00:00:01:09")}
          ]
        },
        %Giraphe.Switch{name: "192.0.2.101", polladdr: NetAddr.ip("192.0.2.101"), physaddr: NetAddr.mac_48("00:00:00:00:01:01"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.102", polladdr: NetAddr.ip("192.0.2.102"), physaddr: NetAddr.mac_48("00:00:00:00:01:02"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.103", polladdr: NetAddr.ip("192.0.2.103"), physaddr: NetAddr.mac_48("00:00:00:00:01:03"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.104", polladdr: NetAddr.ip("192.0.2.104"), physaddr: NetAddr.mac_48("00:00:00:00:01:04"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.105", polladdr: NetAddr.ip("192.0.2.105"), physaddr: NetAddr.mac_48("00:00:00:00:01:05"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.106", polladdr: NetAddr.ip("192.0.2.106"), physaddr: NetAddr.mac_48("00:00:00:00:01:06"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.107", polladdr: NetAddr.ip("192.0.2.107"), physaddr: NetAddr.mac_48("00:00:00:00:01:07"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.108", polladdr: NetAddr.ip("192.0.2.108"), physaddr: NetAddr.mac_48("00:00:00:00:01:08"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.109", polladdr: NetAddr.ip("192.0.2.109"), physaddr: NetAddr.mac_48("00:00:00:00:01:09"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.110", polladdr: NetAddr.ip("192.0.2.110"), physaddr: NetAddr.mac_48("00:00:00:00:01:10"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.120", polladdr: NetAddr.ip("192.0.2.120"), physaddr: NetAddr.mac_48("00:00:00:00:01:20"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.130", polladdr: NetAddr.ip("192.0.2.130"), physaddr: NetAddr.mac_48("00:00:00:00:01:30"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.140", polladdr: NetAddr.ip("192.0.2.140"), physaddr: NetAddr.mac_48("00:00:00:00:01:40"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.150", polladdr: NetAddr.ip("192.0.2.150"), physaddr: NetAddr.mac_48("00:00:00:00:01:50"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.160", polladdr: NetAddr.ip("192.0.2.160"), physaddr: NetAddr.mac_48("00:00:00:00:01:60"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.170", polladdr: NetAddr.ip("192.0.2.170"), physaddr: NetAddr.mac_48("00:00:00:00:01:70"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.180", polladdr: NetAddr.ip("192.0.2.180"), physaddr: NetAddr.mac_48("00:00:00:00:01:80"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.190", polladdr: NetAddr.ip("192.0.2.190"), physaddr: NetAddr.mac_48("00:00:00:00:01:90"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        },
        %Giraphe.Switch{name: "192.0.2.200", polladdr: NetAddr.ip("192.0.2.200"), physaddr: NetAddr.mac_48("00:00:00:00:02:00"), uplink: "Gi1/24",
          fdb: [{"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01")}]
        }
      ]

    assert generate_digraph_from_switches(switches) ==
"""
digraph G {
  graph [
    outputorder=edgesfirst
    rankdir=LR
    forcelabels=true
    splines=ortho
  ];

  node [
    shape=rect
    fillcolor=2
    fixedsize=true
    width=2.5
    height=0.25
    style=filled
    fontname="sans bold"
    fontsize=12
    fontcolor=7
    penwidth=2
    colorscheme=blues7
    color=7
  ];

  edge [
    minlen=4
    penwidth=2
    colorscheme=blues7
    color=3
    labelangle=0
    labeldistance=2.5
    labelfontname="sans bold"
    labelfontsize=10
    labelfontcolor=7
    dir=none
  ];


  // Switches


  "192.0.2.3" [height=19.5];


  "192.0.2.7" [height=19.0];


  "192.0.2.10" [height=0.25];


  "192.0.2.20" [height=0.25];


  "192.0.2.30" [height=0.25];


  "192.0.2.40" [height=0.25];


  "192.0.2.50" [height=4.5];


  "192.0.2.51" [height=0.25];


  "192.0.2.52" [height=0.25];


  "192.0.2.53" [height=0.25];


  "192.0.2.54" [height=0.25];


  "192.0.2.55" [height=2.0];


  "192.0.2.56" [height=0.25];


  "192.0.2.57" [height=0.25];


  "192.0.2.58" [height=0.25];


  "192.0.2.59" [height=0.25];


  "192.0.2.60" [height=0.25];


  "192.0.2.70" [height=0.25];


  "192.0.2.80" [height=0.25];


  "192.0.2.90" [height=0.25];


  "192.0.2.100" [height=4.5];


  "192.0.2.101" [height=0.25];


  "192.0.2.102" [height=0.25];


  "192.0.2.103" [height=0.25];


  "192.0.2.104" [height=0.25];


  "192.0.2.105" [height=0.25];


  "192.0.2.106" [height=0.25];


  "192.0.2.107" [height=0.25];


  "192.0.2.108" [height=0.25];


  "192.0.2.109" [height=0.25];


  "192.0.2.110" [height=0.25];


  "192.0.2.120" [height=0.25];


  "192.0.2.130" [height=0.25];


  "192.0.2.140" [height=0.25];


  "192.0.2.150" [height=0.25];


  "192.0.2.160" [height=0.25];


  "192.0.2.170" [height=0.25];


  "192.0.2.180" [height=0.25];


  "192.0.2.190" [height=0.25];


  "192.0.2.200" [height=0.25];



  // Edges


  "192.0.2.3" -> "192.0.2.7" [taillabel="Gi1/1" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.10" [taillabel="Gi1/1" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.20" [taillabel="Gi1/2" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.30" [taillabel="Gi1/3" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.40" [taillabel="Gi1/4" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.50" [taillabel="Gi1/5" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.60" [taillabel="Gi1/6" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.70" [taillabel="Gi1/7" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.80" [taillabel="Gi1/8" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.90" [taillabel="Gi1/9" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.100" [taillabel="Gi1/10" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.110" [taillabel="Gi1/11" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.120" [taillabel="Gi1/12" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.130" [taillabel="Gi1/13" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.140" [taillabel="Gi1/14" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.150" [taillabel="Gi1/15" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.160" [taillabel="Gi1/16" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.170" [taillabel="Gi1/17" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.180" [taillabel="Gi1/18" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.190" [taillabel="Gi1/19" headlabel="Gi1/24"];


  "192.0.2.7" -> "192.0.2.200" [taillabel="Gi1/20" headlabel="Gi1/24"];


  "192.0.2.50" -> "192.0.2.51" [taillabel="Gi1/1" headlabel="Gi1/24"];


  "192.0.2.50" -> "192.0.2.52" [taillabel="Gi1/2" headlabel="Gi1/24"];


  "192.0.2.50" -> "192.0.2.53" [taillabel="Gi1/3" headlabel="Gi1/24"];


  "192.0.2.50" -> "192.0.2.54" [taillabel="Gi1/4" headlabel="Gi1/24"];


  "192.0.2.50" -> "192.0.2.55" [taillabel="Gi1/5" headlabel="Gi1/24"];


  "192.0.2.55" -> "192.0.2.56" [taillabel="Gi1/1" headlabel="Gi1/24"];


  "192.0.2.55" -> "192.0.2.57" [taillabel="Gi1/2" headlabel="Gi1/24"];


  "192.0.2.55" -> "192.0.2.58" [taillabel="Gi1/3" headlabel="Gi1/24"];


  "192.0.2.55" -> "192.0.2.59" [taillabel="Gi1/4" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.101" [taillabel="Gi1/1" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.102" [taillabel="Gi1/2" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.103" [taillabel="Gi1/3" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.104" [taillabel="Gi1/4" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.105" [taillabel="Gi1/5" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.106" [taillabel="Gi1/6" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.107" [taillabel="Gi1/7" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.108" [taillabel="Gi1/8" headlabel="Gi1/24"];


  "192.0.2.100" -> "192.0.2.109" [taillabel="Gi1/9" headlabel="Gi1/24"];

}
"""
  end
end
