# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe do
  @moduledoc """
  Giraphe escript module.
  """

  alias Giraphe.{Discover, Graph, Render, Utility}

  require Logger

  defp init_session_parameters,
    do: Agent.start_link(fn -> [] end, name: __MODULE__)

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
    for arg <- String.split(string),
      do: arg_to_atom(arg)
  end

  defp parse_credentials(text) do
    text
      |> String.split("\n")
      |> Enum.map(&args_to_atoms/1)
      |> Enum.filter(& length(&1) >= 1)
      |> Enum.group_by(
        fn [type|_] -> type end,
        fn [type|credential] -> {type, credential} end
      )
      |> Map.values
      |> Enum.concat
  end

  defp handle_switches(switches) do
    credentials_result =
      with path when not is_nil(path)
            <- switches[:credentials],

          {:ok, text}
            <- File.read(Path.expand(path)),

          [{:snmp, _}|_] = credentials
            <- parse_credentials(text)
      do
        :ok =
          :giraphe
          |> Application.put_env(:credentials, credentials)

        :ok
      end

    case credentials_result do
      :ok ->
        nil

      nil ->
        usage()

      {:error, _} ->
        usage "Unable to read credentials file: '#{switches[:credentials]}'"

      _ ->
        usage "Unable to parse credentials file: '#{switches[:credentials]}'"
    end

    if path = switches[:output_file] do
      set_session_parameter(:output_file, Path.expand(path))
    end

    if path = switches[:export_path] do
      set_session_parameter(:export_path, Path.expand(path))
    end

    if path = switches[:hosts_file] do
      set_session_parameter(:hosts_file, Path.expand(path))
    end

    if switches[:info] do
      :ok = Logger.configure([level: :info])
    end

    if switches[:debug] do
      :ok = Logger.configure([level: :debug])
    end

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
          credentials: :string,
        ],
        aliases: [
           q: :quiet,
           v: :info,
          vv: :debug,
           o: :output_file,
           x: :export_path,
           h: :hosts_file,
           c: :credentials,
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
                   [-x <export_path>] [-h <hosts_file>]
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose ('-vv' is more verbose)

      -o: output file (must end in .png or .svg)
      -x: export routes to path
      -h: discover hosts and export to file (takes a long time!)

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
    :ok = IO.puts :stderr, message

    usage()
  end

  defp graph_l2(gateway_address, subnet) do
    if Utility.is_host_address gateway_address do
      output_file = get_session_parameter :output_file
      template =
        File.read! "priv/templates/l2_graph.dot.eex"

      gateway_address
      |> Discover.L2.discover_switches(subnet)
      |> Graph.L2.graph_devices(template)
      |> Render.render_graph(output_file)

      :ok = Utility.status "Done!"
    else
      usage "No valid gateway address found."
    end
  end

  defp discover_routers(targets) do
    targets
    |> Enum.filter(&Utility.is_host_address/1)
    |> Discover.L3.discover_routers
  end

  defp graph_l3(targets) do
    routers    = discover_routers targets
    incidences = Graph.L3.abduce_incidences routers

    output_file = get_session_parameter :output_file
    export_path = get_session_parameter :export_path

    _ =
      if export_path do
        :ok = Utility.status "Exporting routes to #{inspect export_path}"

        Giraphe.IO.export_routes(routers, export_path)
      end

    _ = [
      {:dot,     Path.rootname(output_file) <> ".dot"},
      {:graphml, Path.rootname(output_file) <> ".graphml"},

    ] |> Enum.map(fn {format, path} ->
      :ok = Utility.status "Exporting #{format} to #{path}"

      Giraphe.IO.export_l3_notation(
        format,
        incidences,
        routers,
        path
      )
    end)

    template =
      :giraphe
      |> Application.get_env(:l3_graph_template)
      |> File.read!

    :ok = Utility.status "Generating graph"

    incidences
    |> Enum.map(fn
      {router, <<_::binary>> = edge} ->
        {router, edge}

      {router, edge} ->
        {router, NetAddr.prefix(edge)}
    end)
    |> Utility.evaluate_l3_template(routers, template)
    |> Render.render_graph(output_file)

    hosts_file = get_session_parameter :hosts_file

    _ =
      if hosts_file do
        :ok = Utility.status "Discovering hosts... (This may take a while.)"

        routers
        |> Giraphe.Discover.L3.discover_hosts
        |> Giraphe.IO.export_hosts(hosts_file)
      end

    :ok = Utility.status "Done!"
  end

  def main(argv) do
    _ = init_session_parameters()

    case parse_args argv do
      [] ->
        usage()

      ["-2", gateway_string | subnet_args] ->
        subnet = List.first parse_ip_args(subnet_args)

        gateway_string
        |> NetAddr.ip
        |> graph_l2(subnet)

      ["-3" | target_strings] ->
        target_strings
        |> parse_ip_args
        |> graph_l3

      _ ->
        usage()
    end
  end
end
