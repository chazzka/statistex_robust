defmodule Statistex.RobustTest do
  use ExUnit.Case
  doctest Statistex.Robust

  test "medcouple" do
    arr = [1.0, 2.0, 3.0, 3.0, 4.0]
    assert Statistex.Robust.medcouple(arr) == -0.1666666667
  end

  test "adjusted box" do
    zeroth1 =
      Statistex.Robust.adjusted_box([[1, 2], [2, 2], [3, 2]], 0)

    zeroth2 =
      Statistex.Robust.adjusted_box([1, 2, 3])

    assert zeroth1 == {-2.0, 6.0}
    assert zeroth1 == zeroth2

    first1 =
      Statistex.Robust.adjusted_box([[1, 2], [2, 2], [3, 2]], 1)

    first2 =
      Statistex.Robust.adjusted_box([2, 2, 2])

    assert first1 == {2.0, 2.0}
    assert first1 == first2

    assert [
             [57],
             [57],
             [57],
             [58],
             [63],
             [66],
             [66],
             [67],
             [67],
             [68],
             [69],
             [70],
             [70],
             [70],
             [70],
             [72],
             [73],
             [75],
             [75],
             [76],
             [76],
             [78],
             [79],
             [81]
           ]
           |> Statistex.Robust.adjusted_box(0) ==
             {50.61913094289889, 86.344994595386}
  end

  test "Z score" do
    assert [
             54.9671,
             48.6174,
             56.4769,
             65.2303,
             47.6585,
             47.6586,
             65.7921,
             57.6743,
             45.3053,
             65.4256,
             54.3021,
             47.4933,
             58.4903,
             58.3157,
             51.8664,
             62.3844,
             45.8714,
             57.1107,
             51.9618,
             60.4720
           ]
           |> Statistex.Robust.z_score(3) ==
             {35.05825715175857, 75.24916284824144}

    assert [
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
           ]
           |> Statistex.Robust.z_score(3) ==
             {29.837277543944065, 71.04322245605594}
  end

  # test "Iquantile" do
  #   Statistex.Robust.lmlhhm([
  #     57,
  #     57,
  #     57,
  #     58,
  #     63,
  #     66,
  #     66,
  #     67,
  #     67,
  #     68,
  #     69,
  #     70,
  #     70,
  #     70,
  #     70,
  #     72,
  #     73,
  #     75,
  #     75,
  #     76,
  #     76,
  #     78,
  #     79,
  #     81
  #   ])
  #   |> IO.inspect()
  # end
end
