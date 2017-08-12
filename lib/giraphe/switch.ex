# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Switch do
  @moduledoc """
  Defines a struct for storing forwarding database entries
  and other switch information.
  """

  defstruct [
    :name,
    :physaddr,
    :fdb,
    :polladdr,
    :uplink
  ]

  @type name     :: String.t
  @type physaddr :: NetAddr.t
  @type polladdr :: NetAddr.t
  @type portname :: String.t

  @type t :: %__MODULE__{
        name: name,
    physaddr: physaddr,
         fdb: [{portname, physaddr}],
    polladdr: polladdr,
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
