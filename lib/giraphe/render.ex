# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Render do
  @moduledoc """
  A behaviour for renderer implementations.
  """
  @type reason :: atom

  @callback render_graph(
    notation :: String.t,
    format   :: String.t
  ) :: String.t


  defp renderer do
    Application.get_env(:giraphe, :renderer)
  end

  def render_graph(notation, format) do
    renderer().render_graph(notation, format)
  end
end
