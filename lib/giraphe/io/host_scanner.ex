defmodule Giraphe.IO.HostScanner do
  @moduledoc """
  A behaviour for host-scanning implementations.
  """

  @doc "Scans all hosts in `subnet`."
  @callback scan(subnet :: String.t) :: :ok | {:error, reason :: any}
end
