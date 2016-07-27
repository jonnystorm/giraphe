# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Utility do
  @moduledoc false

  def find_prefix_containing_address(prefixes, address) do
    Enum.find prefixes, &NetAddr.contains?(&1, address)
  end

  def get_destinations_from_routes(routes) do
    routes
      |> unzip_and_get_elem(0)
      |> Enum.sort
      |> Enum.dedup
  end

  def get_next_hops_from_routes(routes) do
    routes
      |> unzip_and_get_elem(1)
      |> Enum.sort
      |> Enum.dedup
  end

  def is_host_address(address) do
    NetAddr.first_address(address) == NetAddr.last_address(address)
  end

  def next_hop_is_self(address) do
    NetAddr.ip("0.0.0.0") == address || NetAddr.ip("::") == address
  end

  def next_hop_is_not_self(address) do
    not next_hop_is_self address
  end

  def rjust_and_concat(strings, lengths) do
    strings
      |> Enum.zip(lengths)
      |> Enum.map_join(fn {string, len} -> String.rjust(string, len) end)
  end

  def unzip_and_get_elem(zipped, e) do
    zipped
      |> Enum.unzip
      |> elem(e)
  end
end
