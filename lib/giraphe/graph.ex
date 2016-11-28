# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Graph do
  @moduledoc """
  A behaviour for grapher implementations.
  """
  @type device :: Giraphe.Router.t | Giraphe.Switch.t
  @type reason :: atom

  @doc "Generate graph from devices"
  @callback graph_devices(devices :: [device], template_path :: String.t) :: :ok | {:error, reason}


  defp l2_grapher do
    Application.get_env(:giraphe, :l2_grapher)
  end

  defp l3_grapher do
    Application.get_env(:giraphe, :l3_grapher)
  end

  defp l2_graph_template do
    Application.get_env(:giraphe, :l2_graph_template)
  end

  defp l3_graph_template do
    Application.get_env(:giraphe, :l3_graph_template)
  end

  @doc """
  Delegates to L3 grapher module.
  """
  def graph_routers(routers) do
    l3_grapher.graph_devices(routers, l3_graph_template)
  end

  @doc """
  Delegates to L2 grapher module.
  """
  def graph_switches(switches) do
    l2_grapher.graph_devices(switches, l2_graph_template)
  end
end
