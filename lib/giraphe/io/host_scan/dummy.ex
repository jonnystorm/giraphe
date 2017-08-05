# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.IO.HostScan.Dummy do
  @moduledoc false

  def scan(_subnet) do
    :ok
  end

  def udp_161_open?(_target) do
    true
  end
end
