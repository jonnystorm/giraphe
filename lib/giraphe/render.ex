# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Render do
  @moduledoc """
  A behaviour for renderer implementations.
  """
  @type reason :: atom

  @callback render_l2_graph(graph :: String.t, output_filename :: String.t) :: :ok | {:error, reason}

  @callback render_l3_graph(graph :: String.t, output_filename :: String.t) :: :ok | {:error, reason}


  defp renderer do
    Application.get_env :giraphe, :renderer
  end

  def render_l2_graph(graph, output_filename) do
    renderer.render_l2_graph graph, output_filename
  end

  def render_l3_graph(graph, output_filename) do
    renderer.render_l3_graph graph, output_filename
  end
end
