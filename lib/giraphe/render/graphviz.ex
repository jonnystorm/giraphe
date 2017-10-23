# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render.GraphViz do
  @moduledoc """
  A renderer implementation for GraphViz
  """

  @behaviour Giraphe.Render

  require Logger

  defp execute_dot(format, notation) do
    dot  = String.replace(notation, "'", "\"")
    int  = System.unique_integer [:positive]
    temp = Path.join(System.tmp_dir!, to_string(int))
    args = "-T#{format} -o #{temp}"

    _ =
      """
      which dot &>/dev/null &&
        echo '#{dot}' |
        /usr/bin/env dot #{args} 2>/dev/null
      """
      |> String.to_charlist
      |> :os.cmd

    File.read! temp
  end

  def render_graph(notation, format),
    do: execute_dot(format, notation)
end
