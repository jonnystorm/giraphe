# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe do
  alias Giraphe.Utility

  require Logger

  defp arg_to_atom("snmp"),do: :snmp
  defp arg_to_atom("v1"),  do: :v1
  defp arg_to_atom("v2c"), do: :v2c
  defp arg_to_atom("v3"),  do: :v3
  defp arg_to_atom("noAuthNoPriv"), do: :no_auth_no_priv
  defp arg_to_atom("authNoPriv"),   do: :auth_no_priv
  defp arg_to_atom("authPriv"),     do: :auth_priv
  defp arg_to_atom("md5"), do: :md5
  defp arg_to_atom("sha"), do: :sha
  defp arg_to_atom("dsa"), do: :dsa
  defp arg_to_atom("aes"), do: :aes
  defp arg_to_atom(other), do: other

  defp args_to_atoms(string) do
    for arg <- String.split(string) do
      arg_to_atom arg
    end
  end
  defp parse_credentials(text) do
    text
      |> String.split("\n")
      |> Enum.map(&args_to_atoms/1)
  end

  defp handle_switches(switches) do
    if path = switches[:credentials] do
      with {:ok, text} <- File.read(Path.expand path),
           [_ | _] = credentials <- parse_credentials(text)
      do
        credentials =
          (for [_ | _] = credential <- credentials, do: credential)
            |> Enum.group_by(fn [type | _] -> type end, fn [t | c] -> {t, c} end)
            |> Map.values
            |> Enum.concat

        case credentials do
          [{:snmp, _} | _] ->
            :ok = Application.put_env :giraphe, :credentials, credentials

          _ ->
            usage "Invalid credentials: '#{inspect credentials}'"
        end
      end
    else
      usage
    end

    if switches[:info] do
      :ok = Logger.configure [level: :info]
    end

    if switches[:debug] do
      :ok = Logger.configure [level: :debug]
    end

    if switches[:quiet] do
      :ok = Application.put_env :giraphe, :quiet, true

      :ok = Logger.configure [level: :error]
    end
  end

  defp parse_args(argv) do
    {switches, args, _} =
      OptionParser.parse(argv,
        switches: [
          quiet: :boolean,
          info: :boolean,
          debug: :boolean,
          credentials: :string
        ],
        aliases: [
          q: :quiet,
          v: :info,
          vv: :debug,
          c: :credentials
        ]
      )

    handle_switches switches

    args
  end

  defp parse_ip_args(list) do
    list
      |> Enum.map(&NetAddr.ip/1)
      |> Enum.filter(fn {:error, _} -> false; _ -> true end)
  end

  defp usage do
    IO.puts(:stderr,
    """
    Usage: giraphe [-qv] -c <credentials_path>
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose (more 'v's is more verbose)

      -c: Specify file containing credentials
        <credentials_path>: path to file containing credentials

      -2: generate layer-2 topology
         <gateway_ip>: IP address of target subnet gateway
        <subnet_cidr>: Specifies switch subnet to graph

      -3: generate layer-3 topology
        <router_ip>: IP address of seed target router; with no seed specified,
                     this machines's default gateway is used
    """)

    exit {:shutdown, 1}
  end
  defp usage(message) do
    IO.puts :stderr, message
    usage

    exit {:shutdown, 1}
  end

  def main(argv) do
    case parse_args argv do
      [] ->
        usage

      ["-2", gateway_string | subnet_args] ->
        gateway_address = NetAddr.ip gateway_string

        if Utility.is_host_address gateway_address do
          subnet = List.first parse_ip_args(subnet_args)

          gateway_address
            |> Giraphe.L2.Discovery.discover(subnet)
            |> Giraphe.L2.Dot.generate_digraph_from_switches
            |> IO.puts

        else
          usage "No valid gateway address found."
        end

      ["-3" | target_strings] ->
        targets =
          target_strings
            |> parse_ip_args
            |> Enum.filter(&Utility.is_host_address/1)

        targets
          |> Giraphe.L3.Discovery.discover
          |> Giraphe.L3.Dot.generate_graph_from_routers
          |> IO.puts

      _ ->
        usage
    end
  end
end
