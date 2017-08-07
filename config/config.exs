# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :warn

config :net_snmp_ex,
  max_repetitions: 100

config :giraphe,
  oui_list_path: "/usr/share/nmap/nmap-mac-prefixes"

import_config "#{Mix.env}.exs"

