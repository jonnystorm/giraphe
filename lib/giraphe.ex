# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe do
  @moduledoc """
  Giraphe escript module.
  """

  alias Giraphe.{Discover, Graph, Render, Utility}

  require Logger

  defp init_session_parameters do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  defp get_session_parameter(key) do
    Agent.get(__MODULE__, &Keyword.get(&1, key))
  end

  defp set_session_parameter(key, value) do
    Agent.update(__MODULE__, &Keyword.put(&1, key, value))
  end

  defp arg_to_atom("snmp"), do: :snmp
  defp arg_to_atom("v1"),   do: :v1
  defp arg_to_atom("v2c"),  do: :v2c
  defp arg_to_atom("v3"),   do: :v3
  defp arg_to_atom("noAuthNoPriv"), do: :no_auth_no_priv
  defp arg_to_atom("authNoPriv"),   do: :auth_no_priv
  defp arg_to_atom("authPriv"),     do: :auth_priv
  defp arg_to_atom("md5"),  do: :md5
  defp arg_to_atom("sha"),  do: :sha
  defp arg_to_atom("dsa"),  do: :dsa
  defp arg_to_atom("aes"),  do: :aes
  defp arg_to_atom(other),  do: other

  defp args_to_atoms(string) do
    for arg <- String.split(string), do: arg_to_atom(arg)
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
    credentials_result =
      with     path when not is_nil(path) <- switches[:credentials],
                              {:ok, text} <- File.read(Path.expand path),
           credentials = [{:snmp, _} | _] <- parse_credentials(text)
      do
        :ok = Application.put_env(:giraphe, :credentials, credentials)

        :ok
      end

    case credentials_result do
      :ok ->
        nil

      nil ->
        usage

      {:error, _} ->
        usage "Unable to read credentials file: '#{switches[:credentials]}'"

      _ ->
        usage "Unable to parse credentials file: '#{switches[:credentials]}'"
    end

    if path = switches[:output_file], do:
      set_session_parameter(:output_file, Path.expand(path))

    if path = switches[:export_path] do
      set_session_parameter(:export_path, Path.expand(path))
    end

    if switches[:info], do:
      :ok = Logger.configure([level: :info])

    if switches[:debug], do:
      :ok = Logger.configure([level: :debug])

    if switches[:quiet] do
      :ok = Application.put_env(:giraphe, :quiet, true)

      :ok = Logger.configure([level: :error])
    end
  end

  defp parse_args(argv) do
    {switches, args, _} =
      OptionParser.parse(argv,
        switches: [
          quiet: :boolean,
          info:  :boolean,
          debug: :boolean,
          output_file: :string,
          export_path: :string,
          credentials: :string
        ],
        aliases: [
           q: :quiet,
           v: :info,
          vv: :debug,
           o: :output_file,
           x: :export_path,
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
                   [-dgr -x <export_path>]
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose ('-vv' is more verbose)

      -o: output file (must end in .png or .svg)
      -x: export routes to path

      -c: Specify file containing credentials
        <credentials_path>: path to file containing credentials

        Valid lines in this file will look like one of the following:
          snmp v2c 'r34D0n1Y!'
          snmp v3 noAuthNoPriv 'admin'
          snmp v3 authNoPriv 'admin' md5 '$3cR3t!'
          snmp v3 authPriv 'admin' sha '$3crR3t!' aes 'pR1v473!'

      -2: generate layer-2 topology
         <gateway_ip>: IP address of target subnet gateway
        <subnet_cidr>: Specifies switch subnet to graph

      -3: generate layer-3 topology
        <router_ip>: IP address of seed target router; with no seed specified,
                     this machines's default gateway is used
    """)

    System.halt 1
  end
  defp usage(message) do
    IO.puts :stderr, message
    usage

    System.halt 1
  end

  defp routes_to_string(routes) do
    routes
      |> Stream.map(fn {destination, next_hop} ->
        "#{destination} => #{NetAddr.address(next_hop)}"
      end)
      |> Enum.join("\n")
  end

  defp export_routes(routers, nil), do: routers
  defp export_routes(routers, export_path) do
    Enum.map(routers, fn router ->
      path = Path.join([export_path, "#{router.name}.txt"])

      with {:error, error} <- File.write(path, routes_to_string(router.routes))
      do
        Logger.error("Failed to export '#{inspect router.routes}'")

        raise("Unable to export routes to #{inspect path}: #{inspect error}")
      end

      router
    end)
  end

  def evaluate_l3_template(incidences, routers, template_path) do
    evaluate_l3_template(incidences, routers, template_path, "#{DateTime.utc_now}")
  end
  def evaluate_l3_template(incidences, routers, template_path, timestamp) do
    routers = 
      routers
        |> Enum.map(&router_to_node/1)
        |> Enum.sort_by(& &1.id)

    edges =
      incidences
        |> Stream.map(&elem(&1, 1))
        |> Enum.sort
        |> Enum.map(fn <<_::binary>> = s -> s; s -> NetAddr.prefix(s) end)
        |> Enum.dedup

    EEx.eval_file(
      template_path,
      [ timestamp: timestamp,
        routers: routers,
        edges: edges,
        incidences: incidences,
      ]
    )
  end

  defp export_l3_notation(incidences, routers, l3_template, output_file) do
    notation = evaluate_l3_template(incidences, routers, l3_template)

    with {:error, error} <- File.write(output_file, notation)
    do
      Logger.error("Failed to export '#{notation}'")

      raise("Unable to export GraphML to #{inspect output_file}: #{inspect error}")
    end

    incidences
  end

  defp router_to_node(router) do
    %{name: name} = Utility.trim_domain_from_device_sysname(router)

    %{name: name, id: NetAddr.address(router.polladdr)}
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
            |> Discover.discover_l2(subnet)
            |> Graph.L2.graph_devices("priv/templates/l2_graph.dot.eex")
            |> Render.render_graph(output_file)

          Utility.status "Done!"

        else
          usage "No valid gateway address found."
        end

      ["-3" | target_strings] ->
        output_file = get_session_parameter(:output_file)
        export_path = get_session_parameter(:export_path)

        dot_template = "priv/templates/l3_graph.dot.eex"
        graphml_template = "priv/templates/l3_graph.graphml.eex"
        template = Application.get_env(:giraphe, :l3_graph_template)

            dot_path = Path.rootname(output_file) <> ".dot"
        graphml_path = Path.rootname(output_file) <> ".graphml"

        routers =
          target_strings
            |> parse_ip_args
            |> Enum.filter(&Utility.is_host_address/1)
            |> Discover.discover_l3
            |> export_routes(export_path)

        incidences =
          routers
            |> Graph.L3.abduce_incidences
            |> export_l3_notation(routers, graphml_template, graphml_path)
            |> export_l3_notation(routers, dot_template, dot_path)

        incidences
          |> Enum.map(fn
            {router, <<_::binary>> = edge} ->
              {router, edge}

            {router, edge} ->
              {router, NetAddr.prefix(edge)}
          end)
          |> evaluate_l3_template(routers, template)
          |> Render.render_graph(output_file)

        Utility.status "Done!"

      _ ->
        usage
    end
  end
end
