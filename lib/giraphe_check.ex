defmodule GirapheCheck do
  @moduledoc false

  def test do
    Giraphe.main(~w(-c /dev/null -o l3.png -3 192.0.2.1))
  end
end
