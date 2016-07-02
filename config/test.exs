use Mix.Config

config :giraphe,
  l2_querier: Giraphe.IO.DummyL2Querier,
  l3_querier: Giraphe.IO.DummyL3Querier,
  host_scanner: Giraphe.IO.DummyHostScanner

