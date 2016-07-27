# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Giraphe.Switch do
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
