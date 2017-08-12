# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Giraphe.Host do
  @moduledoc """
  Defines a struct for storing host information.
  """

  defstruct [:ip, :mac]

  @type ip  :: NetAddr.t
  @type mac :: NetAddr.MAC_48.t

  @type t :: %__MODULE__{ip: ip, mac: mac}
end

defimpl String.Chars, for: Giraphe.Host do
  import Kernel, except: [to_string: 1]

  defp oui_list_path,
    do: Application.get_env(:giraphe, :oui_list_path)

  defp grep(pattern, path) do
    path
    |> File.stream!
    |> Stream.filter(& &1 =~ pattern)
    |> Enum.to_list
  end

  defp resolve_oui_to_vendor(oui)
      when byte_size(oui) == 6
  do
    match =
      ~r/^#{oui}/i
      |> grep(oui_list_path())
      |> List.first

    if match do
      match
      |> String.trim_trailing
      |> String.split(" ", parts: 2)
      |> List.last
    else
      nil
    end
  end

  defp resolve_oui_to_vendor(_),
    do: nil

  defp resolve_ip_to_hostname(ip) do
    result =
      ip
      |> :binary.bin_to_list
      |> :inet.gethostbyaddr

    case result do
      {:ok, {:hostent, hostname, _, _, _, _}} ->
        hostname

      {:error, _} ->
        nil
    end
  end

  def to_string(host) do
    hostname =
      host.ip
      |> NetAddr.address
      |> resolve_ip_to_hostname

    oui =
      "#{host.mac}"
      |> String.split(":")
      |> Enum.take(3)
      |> Enum.join

    vendor = resolve_oui_to_vendor oui

    "#{NetAddr.address host.ip} (#{hostname}) => #{host.mac} (#{vendor})"
  end
end
