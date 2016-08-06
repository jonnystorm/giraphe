# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Graph do
  defp l2_grapher do
    Application.get_env :giraphe, :l2_grapher
  end

  defp l3_grapher do
    Application.get_env :giraphe, :l3_grapher
  end

  def l2_graph_template do
    Application.get_env :giraphe, :l2_graph_template
  end

  def l3_graph_template do
    Application.get_env :giraphe, :l3_graph_template
  end

  def graph_routers(routers) do
    l3_grapher.graph_routers routers, l3_graph_template
  end

  def graph_switches(switches) do
    l2_grapher.graph_switches switches, l2_graph_template
  end
end
