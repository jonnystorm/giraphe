defmodule Giraphe.Mixfile do
  use Mix.Project

  def project do
    [ app: :giraphe,
      version: "0.0.19",
      name: "giraphe",
      source_url: "https://github.com/jonnystorm/giraphe",
      elixir: "~> 1.3",
      escript: [main_module: Giraphe],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      docs: [
        logo: "giraphe-logo.png",
        extras: ["README.md"],
      ],
    ]
  end

  defp get_env(:test) do
    [ quiet: true,
      l2_graph_template: "priv/templates/dot/l2_test_graph.dot.eex",
      l3_graph_template: "priv/templates/dot/l3_test_graph.dot.eex",
      querier: Giraphe.IO.Query.Dummy,
      host_scanner: Giraphe.IO.HostScan.Dummy,
    ]
  end
  defp get_env(:dev) do
    [credentials: [snmp: [:v2c, "public"]]]
  end
  defp get_env(:prod) do
    []
  end

  def application do
    [ applications: [
        :logger,
        :eex,
        :netaddr_ex,
        :net_snmp_ex,
      ],
      env: [
        quiet: false,
        l2_grapher: Giraphe.Graph.Dot.L2,
        l3_grapher: Giraphe.Graph.Dot.L3,
        l2_graph_template: "priv/templates/dot/l2_graph.dot.eex",
        l3_graph_template: "priv/templates/dot/l3_graph.dot.eex",
        renderer: Giraphe.Render.GraphViz,
        querier: Giraphe.IO.Query.NetSNMP,
        host_scanner: Giraphe.IO.HostScan.Nmap,
        credentials: [],

      ] |> Keyword.merge(get_env(Mix.env))
    ]
  end

  defp deps do
    [ {:credo, "~> 0.4", only: [:dev, :test]},
      {:netaddr_ex, git: "https://github.com/jonnystorm/netaddr-elixir.git"},
      {:net_snmp_ex, git: "https://github.com/jonnystorm/net-snmp-elixir.git"},
      {:ex_doc, "~> 0.13", only: :dev}
    ]
  end
end
