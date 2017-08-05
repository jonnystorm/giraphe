# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render.GraphVizTest do
  use ExUnit.Case
  doctest Giraphe.Render.GraphViz

  import Giraphe.Render.GraphViz

  @moduletag :integrated

  test "Renders layer-3 dot graphs with GraphViz" do
    output_files =
      for format <- ["png", "svg"], suffix <- ["l2", "l3"] do
        "examples/example-#{suffix}.#{format}"
      end

    Enum.map output_files, &File.rm(&1)

    [ File.read!("test/fixtures/example_l2_graph.dot"),
      File.read!("test/fixtures/example_l3_graph.dot")

    ] |> List.duplicate(2)
      |> List.flatten
      |> Enum.zip(output_files)
      |> Enum.map(fn {graph, file} -> render_graph(graph, file) end)

    Enum.map output_files, &assert(File.exists?(&1))
  end
end
