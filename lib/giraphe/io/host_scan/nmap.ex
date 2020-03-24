# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.IO.HostScan.Nmap do
  @moduledoc """
  An `nmap` implementation of the `Giraphe.IO.HostScanner` behaviour.
  """

  @behaviour Giraphe.IO.HostScan

  require Logger

  @doc """
  Scans all hosts in `subnet`.
  """
  def scan(subnet) do
    args = ~w(nmap -n -sn -PE -T4 --max-retries 0 #{subnet})

    case System.cmd("sudo", args) do
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

    case System.cmd("sudo", args, stderr_to_stdout: true) do
      {output, 0} ->
        Regex.match?(~r|Ports: #{port}/open|, output)

      {error, _} ->
        raise "Unable to scan target '#{target}' for SNMP: '#{error}'."
    end
  end
end
