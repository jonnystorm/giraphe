# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.IO.Query do
  @moduledoc """
  A behaviour for querier implementations.
  """

  @type query_object
    :: :addresses
     | :arp_cache
     | :fdb
     | :routes
     | :sysname
     | :sysdescr

  @callback query(
    object :: query_object,
    target :: NetAddr.t
  ) :: {   :ok, NetAddr.t, query_object, any}
     | {:error, NetAddr.t, query_object, any}

  defp querier do
    Application.get_env :giraphe, :querier
  end

  def query(object, target) do
    querier().query object, target
  end
end
