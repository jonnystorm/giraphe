# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe do
  alias Giraphe.Utility

  require Logger

  defp init_session_parameters do
    Agent.start_link fn -> [] end, name: __MODULE__
  end

  defp get_session_parameter(key) do
    Agent.get __MODULE__, &Keyword.fetch!(&1, key)
  end

  defp set_session_parameter(key, value) do
    Agent.update __MODULE__, &Keyword.put(&1, key, value)
  end

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
    for arg <- String.split string do
      arg_to_atom arg
    end
  end

  defp parse_credentials(text) do
    text
      |> String.split("\n")
      |> Enum.map(&args_to_atoms/1)
      |> Enum.filter(&(length(&1) >= 1))
      |> Enum.group_by(fn [type | _] -> type end, fn [t | c] -> {t, c} end)
      |> Map.values
      |> Enum.concat
  end

  defp handle_switches(switches) do
    if path = switches[:credentials] do
      with {:ok, text} <- File.read(Path.expand path),
           [_ | _] = credentials <- parse_credentials(text)
      do
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

    if path = switches[:output_file] do
      set_session_parameter :output_file, Path.expand(path)
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
          output_file: :string,
          credentials: :string
        ],
        aliases: [
           q: :quiet,
           v: :info,
          vv: :debug,
           o: :output_file,
           c: :credentials
        ]
      )

    handle_switches switches

    args
  end

  defp parse_ip_args(list) do
    for ip_string <- list do
      case NetAddr.ip ip_string do
        {:error, reason} ->
          usage "Unable to parse IP address '#{ip_string}': '#{reason}'"

        ip ->
          ip
      end
    end
  end

  defp usage do
    IO.puts(:stderr,
    """
    Usage: giraphe [-qv] -c <credentials_path> -o <output_file>
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose ('-vv' is more verbose)

      -o: output file (without extension)

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
    init_session_parameters

    case parse_args argv do
      [] ->
        usage

      ["-2", gateway_string | subnet_args] ->
        gateway_address = NetAddr.ip gateway_string

        if Utility.is_host_address gateway_address do
          subnet = List.first parse_ip_args(subnet_args)

          output_file = get_session_parameter :output_file

          gateway_address
            |> Giraphe.Discover.discover_l2(subnet)
            |> Giraphe.Graph.graph_switches
            |> Giraphe.Render.render_l2_graph(output_file)

          Utility.status "Done!"

        else
          usage "No valid gateway address found."
        end

      ["-3" | target_strings] ->
        output_file = get_session_parameter :output_file

        target_strings
          |> parse_ip_args
          |> Enum.filter(&Utility.is_host_address/1)
          |> Giraphe.Discover.discover_l3
          |> Giraphe.Graph.graph_routers
          |> Giraphe.Render.render_l3_graph(output_file)

        Utility.status "Done!"
      _ ->
        usage
    end
  end
end
