defmodule Giraphe.Mixfile do
  use Mix.Project

  def project do
    [ app: :giraphe,
      version: "0.0.8",
      name: "giraphe",
      source_url: "https://github.com/jonnystorm/giraphe",
      elixir: "~> 1.3",
      escript: [main_module: Giraphe],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      docs: [
        logo: "giraphe-logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  defp get_env(:test) do
    [ quiet: true,
      querier: Giraphe.IO.Querier.Dummy,
      host_scanner: Giraphe.IO.HostScanner.Dummy,
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
        :net_snmp_ex
      ],
      env: [
        quiet: false,
        querier: Giraphe.IO.Querier.NetSNMP,
        host_scanner: Giraphe.IO.HostScanner.Nmap,
        l2_dot_template: "templates/dot/l2_graph.dot.eex",
        l3_dot_template: "templates/dot/l3_graph.dot.eex",
        credentials: []

      ] |> Keyword.merge(get_env(Mix.env))
    ]
  end

  defp deps do
    [ {:netaddr_ex, git: "https://github.com/jonnystorm/netaddr-elixir.git"},
      {:net_snmp_ex, git: "https://github.com/jonnystorm/net-snmp-elixir.git"},
      {:ex_doc, "~> 0.13", only: :dev}
    ]
  end
end
