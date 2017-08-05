# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
    host_scanner().scan subnet
  end

  def udp_161_open?(target) do
    host_scanner().udp_161_open? target
  end
end
