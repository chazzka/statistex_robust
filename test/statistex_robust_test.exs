defmodule Statistex.RobustTest do
  use ExUnit.Case
  doctest Statistex.Robust
  alias Statistex.Robust

  test "medcouple/1 calculates medcouple" do
    # Test for medcouple function assuming R script is configured correctly
    assert Robust.medcouple([1, 1, 1, 1, 1, 1]) == 0.0
    assert Robust.medcouple([0, 2, 2, 2, 2, 5, 10]) == 0.4
  end

  test "adjusted_box/1 calculates adjusted box for array" do
    assert Robust.adjusted_box([1, 1, 1, 1, 1, 1]) == {1.0, 1.0}
    assert Robust.adjusted_box([0, 1, 2, 3, 4, 5]) == {-4.5, 9.5}
  end

  test "z_score/2 calculates z-score range for array" do
    result =
      Robust.z_score(
        [
          39.0157,
          50.9985,
          45.1634,
          63.6410,
          48.1637,
          54.4420,
          56.6881,
          49.0387,
          51.9994,
          45.2520
        ],
        3
      )

    assert result == {29.837277543944065, 71.04322245605594}
  end

  test "mad/2 calculates MAD for array" do
    assert Robust.mad([1, 2, 3, 4, 5, 6, 7], 3) == {-2.0, 10.0}
    assert Robust.mad([10, 15, 20, 30, 50], 2) == {0, 40}
  end

  test "mad_skew/2 calculates skew-adjusted MAD for array" do
    assert Robust.mad_skew([1, 2, 3, 4, 5, 6, 7], 3) == {-0.5, 8.5}
    assert Robust.mad_skew([10, 15, 20, 30, 50], 4) == {0, 60}
  end

  test "minmax/2 calculates min and max for specified column in a matrix" do
    assert Robust.minmax([[1, 2, 3], [4, 5, 6], [7, 8, 9]], 0) == {1, 7}
    assert Robust.minmax([[10, 20], [5, 15], [25, 30]], 1) == {15, 30}
  end
end
