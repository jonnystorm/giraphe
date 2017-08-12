# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Discover.L2Test do
  use ExUnit.Case
  doctest Giraphe.Discover.L2

  import Giraphe.Discover.L2

  test "Returns list of switches" do
    expected_switches =
      [ %Giraphe.Switch{
          name: "192.0.2.3",
          polladdr: NetAddr.ip("192.0.2.3"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:03"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:07"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:10"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:20"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:30"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:40"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:50"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:51"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:52"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:53"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:54"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:55"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:56"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:57"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:58"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:59"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:60"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:70"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:80"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:90"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:00"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:02"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:03"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:04"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:05"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:06"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:07"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:08"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:09"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:10"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:20"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:30"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:40"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:50"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:60"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:70"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:80"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:90"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:02:00"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.7",
          polladdr: NetAddr.ip("192.0.2.7"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:07"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:10"), 1},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:20"), 1},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:30"), 1},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:40"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:50"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:51"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:52"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:53"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:54"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:55"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:56"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:57"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:58"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:59"), 1},
            {"Gi1/6",  NetAddr.mac_48("00:00:00:00:00:60"), 1},
            {"Gi1/7",  NetAddr.mac_48("00:00:00:00:00:70"), 1},
            {"Gi1/8",  NetAddr.mac_48("00:00:00:00:00:80"), 1},
            {"Gi1/9",  NetAddr.mac_48("00:00:00:00:00:90"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:00"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:01"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:02"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:03"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:04"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:05"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:06"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:07"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:08"), 1},
            {"Gi1/10", NetAddr.mac_48("00:00:00:00:01:09"), 1},
            {"Gi1/11", NetAddr.mac_48("00:00:00:00:01:10"), 1},
            {"Gi1/12", NetAddr.mac_48("00:00:00:00:01:20"), 1},
            {"Gi1/13", NetAddr.mac_48("00:00:00:00:01:30"), 1},
            {"Gi1/14", NetAddr.mac_48("00:00:00:00:01:40"), 1},
            {"Gi1/15", NetAddr.mac_48("00:00:00:00:01:50"), 1},
            {"Gi1/16", NetAddr.mac_48("00:00:00:00:01:60"), 1},
            {"Gi1/17", NetAddr.mac_48("00:00:00:00:01:70"), 1},
            {"Gi1/18", NetAddr.mac_48("00:00:00:00:01:80"), 1},
            {"Gi1/19", NetAddr.mac_48("00:00:00:00:01:90"), 1},
            {"Gi1/20", NetAddr.mac_48("00:00:00:00:02:00"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.10",
          polladdr: NetAddr.ip("192.0.2.10"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:10"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.20",
          polladdr: NetAddr.ip("192.0.2.20"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:20"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.30",
          polladdr: NetAddr.ip("192.0.2.30"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:30"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.40",
          polladdr: NetAddr.ip("192.0.2.40"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:40"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.50",
          polladdr: NetAddr.ip("192.0.2.50"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:50"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:51"), 1},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:52"), 1},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:53"), 1},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:54"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:55"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:56"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:57"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:58"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:00:59"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.51",
          polladdr: NetAddr.ip("192.0.2.51"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:51"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.52",
          polladdr: NetAddr.ip("192.0.2.52"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:52"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.53",
          polladdr: NetAddr.ip("192.0.2.53"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:53"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.54",
          polladdr: NetAddr.ip("192.0.2.54"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:54"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.55",
          polladdr: NetAddr.ip("192.0.2.55"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:55"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:00:56"), 1},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:00:57"), 1},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:00:58"), 1},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:00:59"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.56",
          polladdr: NetAddr.ip("192.0.2.56"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:56"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.57",
          polladdr: NetAddr.ip("192.0.2.57"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:57"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.58",
          polladdr: NetAddr.ip("192.0.2.58"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:58"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.59",
          polladdr: NetAddr.ip("192.0.2.59"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:59"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.60",
          polladdr: NetAddr.ip("192.0.2.60"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:60"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.70",
          polladdr: NetAddr.ip("192.0.2.70"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:70"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.80",
          polladdr: NetAddr.ip("192.0.2.80"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:80"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.90",
          polladdr: NetAddr.ip("192.0.2.90"),
          physaddr: NetAddr.mac_48("00:00:00:00:00:90"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.100",
          polladdr: NetAddr.ip("192.0.2.100"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:00"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
            {"Gi1/1",  NetAddr.mac_48("00:00:00:00:01:01"), 1},
            {"Gi1/2",  NetAddr.mac_48("00:00:00:00:01:02"), 1},
            {"Gi1/3",  NetAddr.mac_48("00:00:00:00:01:03"), 1},
            {"Gi1/4",  NetAddr.mac_48("00:00:00:00:01:04"), 1},
            {"Gi1/5",  NetAddr.mac_48("00:00:00:00:01:05"), 1},
            {"Gi1/6",  NetAddr.mac_48("00:00:00:00:01:06"), 1},
            {"Gi1/7",  NetAddr.mac_48("00:00:00:00:01:07"), 1},
            {"Gi1/8",  NetAddr.mac_48("00:00:00:00:01:08"), 1},
            {"Gi1/9",  NetAddr.mac_48("00:00:00:00:01:09"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.101",
          polladdr: NetAddr.ip("192.0.2.101"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:01"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.102",
          polladdr: NetAddr.ip("192.0.2.102"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:02"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.103",
          polladdr: NetAddr.ip("192.0.2.103"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:03"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.104",
          polladdr: NetAddr.ip("192.0.2.104"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:04"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.105",
          polladdr: NetAddr.ip("192.0.2.105"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:05"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.106",
          polladdr: NetAddr.ip("192.0.2.106"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:06"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.107",
          polladdr: NetAddr.ip("192.0.2.107"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:07"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.108",
          polladdr: NetAddr.ip("192.0.2.108"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:08"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.109",
          polladdr: NetAddr.ip("192.0.2.109"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:09"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.110",
          polladdr: NetAddr.ip("192.0.2.110"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:10"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.120",
          polladdr: NetAddr.ip("192.0.2.120"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:20"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.130",
          polladdr: NetAddr.ip("192.0.2.130"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:30"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.140",
          polladdr: NetAddr.ip("192.0.2.140"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:40"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.150",
          polladdr: NetAddr.ip("192.0.2.150"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:50"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.160",
          polladdr: NetAddr.ip("192.0.2.160"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:60"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.170",
          polladdr: NetAddr.ip("192.0.2.170"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:70"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.180",
          polladdr: NetAddr.ip("192.0.2.180"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:80"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.190",
          polladdr: NetAddr.ip("192.0.2.190"),
          physaddr: NetAddr.mac_48("00:00:00:00:01:90"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
        %Giraphe.Switch{
          name: "192.0.2.200",
          polladdr: NetAddr.ip("192.0.2.200"),
          physaddr: NetAddr.mac_48("00:00:00:00:02:00"),
          uplink: "Gi1/24",
          fdb: [
            {"Gi1/24", NetAddr.mac_48("00:00:00:00:00:01"), 1},
          ]
        },
      ]

    switches =
      discover_switches(NetAddr.ip("192.0.2.1"), nil)

    assert switches == expected_switches
  end
end
