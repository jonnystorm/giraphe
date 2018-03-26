# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.IO do
  @moduledoc false

  alias Giraphe.{
    Host,
    Render,
    Router,
    Switch,
    Utility
  }

  require Logger

  defp get_query_output(query_result, default_fun) do
    case query_result do
      {:ok, _, _, output} ->
        output

      {:error, target, object, reason} ->
        :ok = Logger.warn "Unable to query target '#{target}' for object '#{object}': #{inspect reason}"

        default_fun.(target, reason)
    end
  end

  defp query(object, target, fun) do
    object
    |> Giraphe.IO.Query.query(target)
    |> get_query_output(fun)
  end

  defp find_connected_route_containing_address(
      routes,
      address
  ) do
    Enum.find routes, fn {destination, next_hop} ->
      NetAddr.contains?(destination, address)
      && Utility.address_is_self(next_hop)
    end
  end

  defp find_addresses_with_matching_connected_routes(
    addresses,
    routes
  ) do
    Enum.filter addresses,
      &find_connected_route_containing_address(routes, &1)
  end

  def get_router(target) do
    if is_snmp_agent(target) do
      routes           = get_target_routes    target
      target_addresses = get_target_addresses target

      # Cisco Nexus may have routes that don't correspond to
      # addresses. Also, ASAs provide no routes. In either
      # case, use addresses for routes.
      #
      addresses =
        if length(routes) <= length(target_addresses) do
          target_addresses
        else
          find_addresses_with_matching_connected_routes(
            target_addresses,
            routes
          )
        end

      routes =
        if length(routes) <= length(addresses) do
          Enum.map addresses, fn address ->
            { NetAddr.first_address(address),
              address_to_self_address(address)
            }
          end
        else
          routes
        end

      polladdr =
        target
        |> Utility.refine_address_length(addresses, routes)

      %Router{
             name: get_target_sysname(target),
         polladdr: polladdr,
        addresses: addresses,
           routes: routes
      }

    else
      %Router{
             name: NetAddr.address(target),
         polladdr: target,
        addresses: [target],
           routes: [
            {target, address_to_self_address(target)},
          ]
      }
    end
  end

  defp get_switchport_by_mac(switch, mac) do
    switch.fdb
    |> Enum.filter(fn {_, a, _} ->
      a != switch.physaddr
    end)
    |> Enum.find_value(fn
      {p, ^mac, _} -> p
      _ -> nil
    end)
  end

  @type target
    :: NetAddr.IPv4.t
     | NetAddr.IPv6.t

  @type physaddr    :: NetAddr.MAC_48.t
  @type gateway_mac :: physaddr

  @spec fetch_switch(target, physaddr, gateway_mac)
    :: Switch.t
  def fetch_switch(target, physaddr, gateway_mac) do
    switch =
      %Switch{polladdr: target, physaddr: physaddr}

    if is_snmp_agent(target) do
      switch =
        %{switch |
          name: get_target_sysname(target),
           fdb: get_target_fdb(target)
        }

      %{switch |
        uplink: get_switchport_by_mac(switch, gateway_mac)
      }

    else
      %{switch |
        name: NetAddr.address(target),
        fdb: []
      }
    end
  end

  def get_target_addresses(target) do
    :addresses
    |> query(target, fn(t, _) -> [t] end)
    |> Enum.sort
  end

  def get_target_arp_cache(target) do
    :arp_cache
    |> query(target, fn(_, _) -> [] end)
    |> Enum.sort
  end

  def get_target_fdb(target),
    do: query(:fdb, target, fn(_, _) -> [] end)

  defp address_to_self_address(address) do
    0
    |> List.duplicate(NetAddr.address_size(address))
    |> :binary.list_to_bin
    |> NetAddr.netaddr
  end

  defp aggregate_local_connected_route_pairs(routes) do
    # HP Comware splits connected routes as follows.
    #
    #     192.0.2.0/24 => 192.0.2.1
    #     192.0.2.1/32 => 127.0.0.1
    #
    # Instead, we want
    #
    #     192.0.2.0/24 => 0.0.0.0
    #
    addresses =
      routes
      |> Stream.filter(fn {_, next_hop} ->
        Utility.address_is_localhost(next_hop)
      end)
      |> Enum.map(fn {destination, _} -> destination end)

    routes
    |> Stream.filter(fn {_, next_hop} ->
      Utility.address_is_not_localhost(next_hop)
    end)
    |> Enum.map(fn {destination, next_hop} ->
      new_next_hop =
        if next_hop in addresses do
          address_to_self_address(next_hop)
        else
          next_hop
        end

      {destination, new_next_hop}
    end)
  end

  def get_target_routes(target) do
    # Some devices return a localhost route:
    #
    #   127.0.0.0/8 => 0.0.0.0
    #
    # Hence we filter out such destinations.
    #
    :routes
    |> query(target, fn(_, _) -> [] end)
    |> Enum.filter(fn {destination, _} ->
      not Utility.address_is_localhost(destination)
    end)
    |> Enum.sort
    |> aggregate_local_connected_route_pairs
  end

  def get_target_sysname(target) do
    query(
      :sysname,
      target,
      fn(t, _) -> NetAddr.address(t) end
    )
  end

  def ping_subnet(subnet),
    do: Giraphe.IO.HostScan.scan subnet

  def is_snmp_agent(%{} = target),
    do: Giraphe.IO.HostScan.udp_161_open? target

  def is_snmp_agent(_),
    do: false

  defp routes_to_string(routes) do
    routes
    |> Stream.map(fn {destination, next_hop} ->
      "#{destination} => #{NetAddr.address(next_hop)}"
    end)
    |> Enum.join("\n")
  end

  def export_routes(routers, export_path) do
    _ = File.mkdir_p export_path

    Enum.map routers, fn router ->
      basename = NetAddr.address router.polladdr
      path     = Path.join [export_path, "#{basename}.txt"]
      string   = routes_to_string router.routes

      with {:error, error} <- File.write(path, string)
      do
        :ok = Logger.error("Failed to export '#{inspect router.routes}'")

        raise "Unable to export routes to #{inspect path}: #{inspect error}"
      end
    end
  end

  def export_l3_notation(
    format,
    incidences,
    routers,
    export_path
  ) do
    template_path =
      case format do
        :dot     -> "priv/templates/l3_graph.dot.eex"
        :graphml -> "priv/templates/l3_graph.graphml.eex"
      end

    template = File.read! template_path

    notation =
      incidences
      |> Utility.evaluate_l3_template(routers, template)

    with {:error, error}
           <- File.write(export_path, notation)
    do
      :ok = Logger.error("Failed to export '#{notation}'")

      raise "Unable to export GraphML to #{inspect export_path}: #{inspect error}"
    end
  end

  defp retrieve_arp_entries(subnet, gateway_address) do
    :ok = Utility.status "Retrieving ARP entries from #{gateway_address} for subnet #{subnet}"

    gateway_address
    |> get_target_arp_cache
    |> Enum.filter(fn {netaddress, _} ->
      NetAddr.contains?(subnet, netaddress)
    end)
  end

  defp farm_arp_entries(subnet, gateway_address) do
    :ok = Utility.status "Inducing ARP entries in #{gateway_address} for subnet #{subnet}"

    :ok = ping_subnet subnet

    retrieve_arp_entries(subnet, gateway_address)
  end

  @type subnet          :: NetAddr.t
  @type gateway_address :: NetAddr.t
  @type host            :: Host.t
  @type hosts           :: [host]

  @spec enumerate_hosts(subnet, gateway_address)
    :: hosts
  def enumerate_hosts(subnet, gateway_address) do
    hosts =
      subnet
      |> farm_arp_entries(gateway_address)
      |> Enum.map(fn {netaddress, physaddress} ->
        %Host{ip: netaddress, mac: physaddress}
      end)

    gateway_host =
      Enum.find(hosts, & &1.ip == gateway_address)

    if is_nil gateway_host do
      [ %Host{
          ip: gateway_address,
          mac: NetAddr.mac_48("00:00:00:00:00:00"),
        }
        | hosts
      ]
    else
      hosts
    end
  end

  def export_hosts(hosts, hosts_file) do
    string =
      hosts
      |> Enum.map(& "#{&1}\n")
      |> Enum.join

    with {:error, error} <- File.write(hosts_file, string)
    do
      :ok = Logger.error "Failed to export '#{inspect hosts}'"

      raise "Unable to export routes to #{inspect hosts_file}: #{inspect error}"
    end
  end

  def render_l3_graph(
    incidences,
    routers,
    template,
    output_file
  ) do
    :ok = Utility.status "Rendering graph"

    format =
      output_file
      |> Path.extname
      |> String.trim_leading(".")

    graph =
      incidences
      |> Utility.evaluate_l3_template(routers, template)
      |> Render.GraphViz.render_graph(format)

    with {:error, error} <- File.write(output_file, graph)
    do
      :ok = Logger.error "Failed while writing graph to #{inspect output_file}"

      raise "Unable to write graph to #{inspect output_file}: #{inspect error}"
    end
  end
end
