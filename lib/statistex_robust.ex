defmodule Statistex.Robust do
  @moduledoc """
  Documentation for `Statistex.Robust`.

  Robust (range-based) statistics built on Statistex
  """

  @doc """
    Runs R script to calculate medcouple on array.

    Medcouple is a robust statistic that measures the skewness of a univariate distribution.

    Depends on Rscript (https://www.rdocumentation.org/packages/utils/versions/3.6.2/topics/Rscript).

    Rscript has to be available in shell path.

  ## Examples
      iex> Statistex.Robust.medcouple([1,1,1,1,1,1])
      0.0
      iex> Statistex.Robust.medcouple([0,2,2,2,2,5,10])
      0.4
  """
  def medcouple(arr) do
    {result, _exit_code} =
      System.cmd("Rscript", ["lib/medcouple.R"] ++ (arr |> Enum.map(fn x -> "#{x}" end)))

    String.trim(result) |> String.to_float()
  end

  @doc """
    Runs R script to calculate adjusted box for array (https://en.wikipedia.org/wiki/Box_plot).

    Depends on medcouple calculation (see: Statistex.Robust.medcouple).

    Input is sorted automatically.

  ## Examples
      iex> Statistex.Robust.adjusted_box([1,1,1,1,1,1])
      {1.0, 1.0}
      iex> Statistex.Robust.adjusted_box([0,1,2,3,4,5])
      {-4.5, 9.5}
  """
  def adjusted_box(input) do
    sorted = Enum.sort(input)
    %{25 => fqr, 75 => tqr} = Statistex.percentiles(sorted, [25, 75])
    iqr = tqr - fqr
    med = medcouple(sorted)

    tolerance = fn par -> 1.5 * iqr * :math.exp(par * med) end

    lower_bound = fqr - tolerance.(if med >= 0, do: -4, else: -3)
    upper_bound = tqr + tolerance.(if med >= 0, do: 3, else: 4)

    {lower_bound, upper_bound}
  end

  @doc """
    Runs R script to calculate adjusted box for indexth matrix row (https://en.wikipedia.org/wiki/Box_plot).

    Depends on medcouple calculation (see: Statistex.Robust.medcouple).

    Input is sorted automatically.

  ## Examples
      iex> Statistex.Robust.adjusted_box([[1],[1],[1],[1],[1],[1]], 0)
      {1.0, 1.0}
  """
  def adjusted_box(matrix, index) do
    Enum.map(matrix, fn x -> Enum.at(x, index) end)
    |> adjusted_box
  end

  @doc """
    Experimental function.

    TODO: TEST

  """
  def lmlhhm(arr) do
    %{1 => l, 10 => lm, 90 => hm, 99 => h} = Statistex.percentiles(arr, [1, 10, 90, 99])
    {l - 3 * (lm - l), h + 3 * (h - hm)}
  end

  @doc """
    Estimates range using Z-score.

    Depends on medcouple calculation (see: Statistex.Robust.medcouple).

    Input is sorted automatically.

  ## Examples
      iex> Statistex.Robust.z_score([39.0157, 50.9985, 45.1634, 63.6410, 48.1637, 54.4420, 56.6881, 49.0387, 51.9994, 45.2520], 3)
      {29.837277543944065, 71.04322245605594}
  """
  def z_score(arr, threshold) do
    mean = Statistex.average(arr)
    stdev = Statistex.standard_deviation(arr)
    {mean - threshold * stdev, mean + threshold * stdev}
  end

  @doc """
    Estimates range using Z-score for index'th row of a matrix.

  ## Examples
      iex> Statistex.Robust.z_score([[39.0157], [50.9985], [45.1634], [63.6410], [48.1637], [54.4420], [56.6881], [49.0387], [51.9994], [45.2520]], 3,0)
      {29.837277543944065, 71.04322245605594}
  """
  def z_score(matrix, threshold, index) do
    matrix
    |> Enum.map(fn x -> Enum.at(x, index) end)
    |> z_score(threshold)
  end

  def mad_skew(arr, threshold \\ 3) do
    med = Statistex.median(arr)
    diff = arr |> Enum.map(&(&1 - med))
    neg = diff |> Enum.filter(&(&1 <= 0)) |> Statistex.median()
    pos = diff |> Enum.filter(&(&1 >= 0)) |> Statistex.median()

    {med + threshold * neg, med + threshold * pos}
  end

  @doc """
    Estimates range using Median Absolute Deviation

  ## Examples

  """
  def mad(arr, threshold \\ 3) do
    med = Statistex.median(arr)
    mad = arr |> Enum.map(&abs(&1 - med)) |> Statistex.median()
    {med - threshold * mad, med + threshold * mad}
  end

  @doc """
    Estimates range using Median Absolute Deviation for indeth row of matrix

  ## Examples

  """
  def mad(matrix, threshold, index) do
    Enum.map(matrix, fn x -> Enum.at(x, index) end) |> mad(threshold)
  end
end
