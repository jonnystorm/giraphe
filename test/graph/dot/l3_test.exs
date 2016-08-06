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

    assert graph_routers(routers, "1970-01-01 00:00:00Z", @template)
      == File.read!("test/graph/dot/l3_graph.dot")
  end
end
