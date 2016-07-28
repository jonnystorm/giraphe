![giraphe title](https://raw.githubusercontent.com/jonnystorm/giraphe/master/giraphe-title.png | height=300)

Discover and visualize layer-2 and layer-3 network topology.

See the [API documentation](http://jonnystorm.github.io/giraphe).

## Installation

  1. Add giraphe to your list of dependencies in `mix.exs`:

        def deps do
          [{:giraphe, git: "https://github.com/jonnystorm/giraphe.git"}]
        end

  2. Ensure giraphe is started before your application:

        def application do
          [applications: [:giraphe]]
        end

