# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.HostScan.Dummy do
  @moduledoc false

  def scan(_subnet) do
    :ok
  end

  def udp_161_open?(_target) do
    true
  end
end
