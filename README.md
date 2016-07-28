<a href="https://github.com/jonnystorm/giraphe"><img src="https://raw.githubusercontent.com/jonnystorm/giraphe/master/giraphe-title.png" height="300px" /></a>

Discover and visualize layer-2 and layer-3 network topology.

See the [API documentation](http://jonnystorm.github.io/giraphe).

## Installation

  1. Add giraphe to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:giraphe, git: "https://github.com/jonnystorm/giraphe.git"}]
    end
    ```

  2. Ensure giraphe is started before your application:

    ```elixir
    def application do
      [applications: [:giraphe]]
    end
    ```

