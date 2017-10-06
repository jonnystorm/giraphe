# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render.GraphVizTest do
  use ExUnit.Case
  doctest Giraphe.Render.GraphViz

  import Giraphe.Render.GraphViz

  @moduletag :integrated

  defp rendered(file),
    do: Path.join ["examples", file]

  defp reference(file),
    do: Path.join ["test/fixtures", file]

  test "Renders dot with GraphViz" do
    output_files =
      for format <- ["png", "svg"],
          suffix <- ["l2", "l3"],

      do: "example-#{suffix}.#{format}"

    _ = Enum.map output_files, &File.rm(&1)

    [ File.read!("test/fixtures/example_l2_graph.dot"),
      File.read!("test/fixtures/example_l3_graph.dot")

    ] |> List.duplicate(2)
      |> List.flatten
      |> Enum.zip(output_files)
      |> Enum.map(fn {notation, file} ->
        file
        |> Path.extname
        |> String.trim_leading(".")
        |> (&render_graph(notation, &1)).()
        |> (&File.write!(rendered(file), &1)).()
      end)

    Enum.map output_files, fn file ->
      assert File.read!(rendered file) ==
        File.read!(reference file)
    end
  end
end
