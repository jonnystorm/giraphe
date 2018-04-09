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
  defp arg_to_atom("des"),  do: :des
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
        usage "Unable to read credentials file: '#{switches[:credentials]}'."

      _ ->
        usage "Unable to parse credentials file: '#{switches[:credentials]}'."
    end

    if path = switches[:output_file] do
      set_session_parameter(:output_file, Path.expand(path))
    else
      usage "Please specify an output file using `-o`."
    end

    if path = switches[:route_export_path] do
      set_session_parameter(:route_export_path, Path.expand(path))
    end

    if path = switches[:routers_file] do
      set_session_parameter(:routers_file, Path.expand(path))
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
          route_export_path: :string,
          credentials: :string,
        ],
        aliases: [
           q: :quiet,
           v: :info,
          vv: :debug,
           o: :output_file,
           x: :route_export_path,
           r: :routers_file,
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
                   [-x <route_export_path>] [-r <routers_file>] [-h <hosts_file>]
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose ('-vv' is more verbose)

      -o: output file (must end in .png or .svg)
      -x: export routes to path
      -r: export routers to file
      -h: discover hosts and export to file (slow!)

      -c: Specify file containing credentials
        <credentials_path>: path to file containing credentials

        Valid lines in this file will look like one of the following:
          snmp v2c 'r34D0n1Y!'
          snmp v3 noAuthNoPriv 'admin'
          snmp v3 authNoPriv 'admin' md5 '$3cR3t!'
          snmp v3 authPriv 'admin' sha '$3cR3t!' aes 'pR1v473!'

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

  defp fetch_template(type) when type in [:l2, :l3] do
    name =
      case type do
        :l2 -> :l2_template
        :l3 -> :l3_template
      end

    :giraphe
    |> Application.get_env(name)
    |> File.read!
  end

  defp l2_template,
    do: fetch_template :l2

  defp l3_template,
    do: fetch_template :l3

  defp generate_l2_graph(gateway_address, subnet) do
    if Utility.is_host_address gateway_address do
      output_file = output_file()
      template    = l2_template()

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

  defp export_notations(incidences, routers, output_file) do
    [ {:dot,     Path.rootname(output_file) <> ".dot"},
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
  end

  defp export_routers(routers, path) do
    if path do
      :ok = Utility.status "Exporting routers to #{inspect path}"

      Giraphe.IO.export_routers(routers, path)
    end
  end

  defp export_routes(routers, path) do
    if path do
      :ok = Utility.status "Exporting routes to #{inspect path}"

      Giraphe.IO.export_routes(routers, path)
    end
  end

  defp enumerate_hosts(routers, path) do
    if path do
      :ok = Utility.status "Discovering hosts... (This may take a while.)"

      routers
      |> Giraphe.Discover.L3.discover_hosts
      |> Giraphe.IO.export_hosts(path)
    end
  end

  defp output_file,
    do: get_session_parameter :output_file

  defp route_export_path,
    do: get_session_parameter :route_export_path

  defp hosts_file,
    do: get_session_parameter :hosts_file

  defp routers_file,
    do: get_session_parameter :routers_file

  defp generate_l3_graph(targets) do
    routers = discover_routers targets
    incidences = Graph.L3.abduce_incidences routers
    output_file = output_file()
    template = l3_template()

    _ =
      Giraphe.IO.render_l3_graph(
        incidences,
        routers,
        template,
        output_file
      )

    _ = export_notations(incidences, routers, output_file)
    _ = export_routers(routers, routers_file())
    _ = export_routes(routers, route_export_path())
    _ = enumerate_hosts(routers, hosts_file())

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
        |> generate_l2_graph(subnet)

      ["-3" | target_strings] ->
        target_strings
        |> parse_ip_args
        |> generate_l3_graph

      _ ->
        usage()
    end
  end
end
