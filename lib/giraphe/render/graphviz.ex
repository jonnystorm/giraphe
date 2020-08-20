# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render.GraphViz do
  @moduledoc """
  A renderer implementation for GraphViz
  """

  require Logger

  alias Giraphe.Utility

  defp execute_dot(format, dot0) do
    dot  = String.replace(dot0, "'", "\"")
    int  = System.unique_integer([:positive])
    temp = Path.join(System.tmp_dir!, to_string(int))
    args = "-T#{format} -o #{temp}"

    if is_nil(Utility.which_dot()) do
      exit(1)
    end

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

  def render_graph(dot, format)
      when is_binary(dot)
       and format in ~w(png svg),
    do: execute_dot(format, dot)
end
