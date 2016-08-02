# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.IO.HostScanner.Nmap do
  @moduledoc """
  An `nmap` implementation of the `Giraphe.IO.HostScanner` behaviour.
  """

  require Logger

  @behaviour Giraphe.IO.HostScanner

  @doc """
  Scans all hosts in `subnet`.
  """
  def scan(subnet) do
    args = ~w(-n -sn -PE -T4 #{subnet})

    case System.cmd "nmap", args, stderr_to_stdout: true do
      {_, 0} ->
        :ok

      {error, _} ->
        raise "Unable to scan subnet '#{subnet}': `#{error}'."
    end
  end

  @doc """
  Tests whether 161/udp is open on `target`.
  """
  def udp_161_open?(target) do
    address = NetAddr.address target
    port = 161
    args = ~w(nmap -n -oG - -sU -p #{port} #{address})

    case System.cmd "sudo", args, stderr_to_stdout: true do
      {output, 0} ->
        Regex.match? ~r|Ports: #{port}/open/|, output

      {error, _} ->
        raise "Unable to scan target '#{target}' for SNMP: '#{error}'."
    end
  end
end
