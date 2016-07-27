# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.NmapHostScanner do
  @moduledoc """
  An `nmap` implementation of the `Giraphe.IO.HostScanner` behaviour.
  """

  @behaviour Giraphe.IO.HostScanner

  @doc """
  Scans all hosts in `subnet`.
  """
  def scan(subnet) do
    case System.cmd("nmap", ~w(-n -sn -PE -T4 #{subnet})) do
      {_, 0} ->
        :ok

      {output, _} ->
        {:error, output}
    end
  end
end
