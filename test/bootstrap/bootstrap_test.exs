defmodule Statistex.Robust.BootstrapTest do
  use ExUnit.Case
  doctest Statistex.Robust.Bootstrap

  test "bootstrap" do
    data = [
      57,
      57,
      57,
      58,
      63,
      66,
      66,
      67,
      67,
      68,
      69,
      70,
      70,
      70,
      70,
      72,
      73,
      75,
      75,
      76,
      76,
      78,
      79,
      81
    ]

    n_resamples = 100
    extrapolation_percentage = 0.10

    assert Statistex.Robust.Bootstrap.extrapolate(data, n_resamples, extrapolation_percentage) ==
             {51.3, 89.1}
  end
end
