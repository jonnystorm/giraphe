# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.HostScan do
  @moduledoc """
  A behaviour for host-scanning implementations.
  """

  @doc "Scans all hosts in `subnet`."
  @callback scan(subnet :: NetAddr.t) :: :ok

  @doc "Tests whether 161/udp is open on `target`."
  @callback udp_161_open?(target :: NetAddr.t) :: boolean


  defp host_scanner do
    Application.get_env :giraphe, :host_scanner
  end

  def scan(subnet) do
    host_scanner.scan subnet
  end

  def udp_161_open?(target) do
    host_scanner.udp_161_open? target
  end
end
