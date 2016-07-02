# Giraphe

Discover and visualize L2/L3 network topology.

## Installation

  1. Add giraphe to your list of dependencies in `mix.exs`:

        def deps do
          [{:giraphe, git: "https://github.com/jonnystorm/giraphe.git"}]
        end

  2. Ensure giraphe is started before your application:

        def application do
          [applications: [:giraphe]]
        end

