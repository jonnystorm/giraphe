defmodule Giraphe.Mixfile do
  use Mix.Project

  def project do
    [ app: :giraphe,
      version: "0.0.5",
      name: "giraphe",
      source_url: "https://github.com/jonnystorm/giraphe",
      elixir: "~> 1.2",
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
    [ l2_querier: Giraphe.IO.DummyL2Querier,
      l3_querier: Giraphe.IO.DummyL3Querier,
      host_scanner: Giraphe.IO.DummyHostScanner,
      l2_dot_template: "templates/dot/l2_graph.dot.eex",
      l3_dot_template: "templates/dot/l3_graph.dot.eex"
    ]
  end
  defp get_env(_) do
    [ l2_querier: Giraphe.IO.SNMPL2Querier,
      l3_querier: Giraphe.IO.SNMPL3Querier,
      host_scanner: Giraphe.IO.NmapHostScanner,
      l2_dot_template: "templates/dot/l2_graph.dot.eex",
      l3_dot_template: "templates/dot/l3_graph.dot.eex"
    ]
  end

  def application do
    [ applications: [
        :logger,
        :netaddr_ex
      ],
      env: get_env(Mix.env)
    ]
  end

  defp deps do
    [ {:netaddr_ex, git: "https://github.com/jonnystorm/netaddr-elixir.git"},
      {:ex_doc, "~> 0.13", only: :dev}
    ]
  end
end
