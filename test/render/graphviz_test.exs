# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Render.GraphVizTest do
  use ExUnit.Case
  doctest Giraphe.Render.GraphViz

  import Giraphe.Render.GraphViz

  test "Renders layer-3 dot graphs with GraphViz" do
    output_files =
      for format <- ["png", "svg"], suffix <- ["l2", "l3"] do
        "examples/example-#{suffix}.#{format}"
      end

    Enum.map output_files, &File.rm(&1)

    [ {&render_l2_graph/2, File.read!("test/graph/dot/l2_graph1.dot")},
      {&render_l3_graph/2, File.read!("test/graph/dot/l3_graph.dot")}

    ] |> List.duplicate(2)
      |> List.flatten
      |> Enum.unzip
      |> Tuple.to_list
      |> Enum.concat([output_files])
      |> List.zip
      |> Enum.map(fn {fun, graph, file} -> fun.(graph, file) end)

    Enum.map output_files, &assert(File.exists?(&1))
  end
end
