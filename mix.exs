defmodule Giraphe.Mixfile do
  use Mix.Project

  def project do
    [ app: :giraphe,
      version: "0.0.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [ applications: [
        :logger,
        :netaddr_ex
      ]
    ]
  end

  defp deps do
    [ {:netaddr_ex, git: "https://github.com/jonnystorm/netaddr-elixir.git"}
    ]
  end
end
