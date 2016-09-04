# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Render.GraphViz do
  @moduledoc """
  A renderer implementation for GraphViz
  """

  @behaviour Giraphe.Render

  require Logger

  defp execute_shell_command(cmd) do
    [status_char | reverse_output] =
      cmd
        |> String.to_charlist
        |> :os.cmd
        |> Enum.reverse

    output = List.to_string Enum.reverse(reverse_output)
    status = String.to_integer List.to_string([status_char])

    {output, status}
  end

  defp execute_dot(format, output_file, graph) do
    graph = String.replace graph, "'", "\""

    args = "-T#{format} -o #{output_file}"
    cmd  = "(echo '#{graph}' | dot #{args} 2>&1); echo -n $?"

    case execute_shell_command(cmd) do
      {_, 0} ->
        :ok

      {error, _} ->
        :ok = Logger.error "GraphViz failure: '#{error}'"
        :ok = Logger.error "Failed to render graph: '#{graph}'"

        raise "Failed to render #{output_file} with GraphViz."
    end
  end

  def render_graph(graph, output_file) do
    format =
      output_file
        |> Path.extname
        |> String.trim_leading(".")

    execute_dot format, output_file, graph
  end
end
