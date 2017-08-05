# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render.GraphViz do
  @moduledoc """
  A renderer implementation for GraphViz
  """

  @behaviour Giraphe.Render

  require Logger

  defp execute_shell_command(cmd) do
    [status_character | reverse_output] =
      cmd
      |> String.to_charlist
      |> :os.cmd
      |> Enum.reverse

    output =
      reverse_output
      |> Enum.reverse
      |> List.to_string

    status =
      [status_character]
      |> List.to_string
      |> String.to_integer

    {output, status}
  end

  defp execute_dot(format, output_file, graph) do
    graph = String.replace(graph, "'", "\"")

    args = "-T#{format} -o #{output_file}"
    cmd =
      "(echo '#{graph}' | dot #{args} 2>&1); echo -n $?"

    case execute_shell_command(cmd) do
      {_, 0} ->
        :ok

      {error, _} ->
        :ok = Logger.error("GraphViz failure: '#{error}'")
        :ok = Logger.error("Failed to render graph: '#{graph}'")

        raise "Failed to render #{output_file} with GraphViz."
    end
  end

  def render_graph(graph, output_file) do
    format =
      output_file
      |> Path.extname
      |> String.trim_leading(".")

    execute_dot(format, output_file, graph)
  end
end
