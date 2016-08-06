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

  defp execute_graphviz_command(command, format, output_file, dot) do
    dot = String.replace dot, "'", "\""

    args = "-T#{format} -o #{output_file}"
    cmd  = "(echo '#{dot}' | #{command} #{args} 2>&1); echo -n $?"

    case execute_shell_command(cmd) do
      {_, 0} ->
        :ok

      {error, _} ->
        :ok = Logger.error "GraphViz failure: '#{error}'"
        :ok = Logger.error "Failed to render graph: '#{dot}'"

        raise "Failed to render #{output_file} with GraphViz."
    end
  end

  defp render_graph(command, output_file, graph) do
    format =
      output_file
        |> Path.extname
        |> String.trim_leading(".")

    execute_graphviz_command command, format, output_file, graph
  end

  def render_l2_graph(graph, output_file) do
    render_graph "dot", output_file, graph
  end

  def render_l3_graph(graph, output_file) do
    render_graph "neato", output_file, graph
  end
end
