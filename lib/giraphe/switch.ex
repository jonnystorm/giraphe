# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Switch do
  @moduledoc """
  Defines a struct for storing forwarding database entries and other
  switch information.
  """

  defstruct name: nil, physaddr: nil, fdb: nil, polladdr: nil, uplink: nil

  @type name     :: String.t
  @type netaddr  :: NetAddr.t
  @type physaddr :: netaddr
  @type portname :: String.t

  @type t :: %Giraphe.Switch{
        name: name,
    physaddr: physaddr,
         fdb: [{portname, physaddr}],
    polladdr: netaddr,
      uplink: portname
  }
end

defimpl String.Chars, for: Giraphe.Switch do
  import Kernel, except: [to_string: 1]

  def to_string(switch) do
    fdb =
      switch.fdb
        |> Enum.map(fn {port, address, vlan} ->
          "#{port}, V#{vlan} => #{address}"
        end)
        |> Enum.join(",\n    ")

    "#{switch.uplink} <- #{switch.name}: #{switch.polladdr} (#{switch.physaddr})
    #{fdb}\n"
  end
end
