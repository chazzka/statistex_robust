defmodule Statistex.Robust do
  @moduledoc """
  Documentation for `Statistex.Robust`.

  Robust (range-based) statistics built on Statistex
  """

  @doc """
  Calculates the minimum and maximum values for a specific column in a matrix.
  This method serves only for comparison with robust methods

  ## Parameters
    - `matrix`: A list of lists (matrix) where each inner list represents a row.
    - `index`: The index of the column for which to find the minimum and maximum values.

  ## Returns
    - A tuple `{min, max}`, representing the minimum and maximum value of the specified column.

  ## Examples

      iex> Statistex.Robust.minmax([[1, 2, 3], [4, 5, 6], [7, 8, 9]], 0)
      {1, 7}

      iex> Statistex.Robust.minmax([[10, 20], [5, 15], [25, 30]], 1)
      {15, 30}
  """
  def minmax(matrix, index) do
    column = Enum.map(matrix, fn row -> Enum.at(row, index) end)
    {Enum.min(column), Enum.max(column)}
  end

  @doc """
  Runs R script to calculate medcouple on array.

  Note that medcouple does NOT return a range, but a value.
  For range estimation using medcouple refer to `adjusted_box/1`.

  Medcouple is a robust statistic that measures the skewness of a univariate distribution.

  Depends on Rscript (https://www.rdocumentation.org/packages/utils/versions/3.6.2/topics/Rscript).
  Depends on library robustbase (https://cran.r-project.org/web/packages/robustbase/index.html)

  Rscript has to be available in shell path.

  ## Examples
      iex> Statistex.Robust.medcouple([1,1,1,1,1,1])
      0.0
      iex> Statistex.Robust.medcouple([0,2,2,2,2,5,10])
      0.4
  """
  def medcouple(arr) do
    args = arr |> Enum.map(&to_string/1)

    # Capture both stdout and stderr
    {result, exit_code} =
      System.cmd("Rscript", ["-e", r_script()] ++ args, stderr_to_stdout: true)

    if exit_code != 0 do
      # Rscript ended with an error, handle it accordingly
      {:error, "Rscript failed with exit code #{exit_code}: #{String.trim(result)}"}
    else
      String.trim(result) |> String.to_float()
    end
  end

  defp r_script do
    """
    if (!requireNamespace("robustbase", quietly = TRUE)) {
      stop("The 'robustbase' package is required but not installed. Please install it using install.packages('robustbase').")
    }
    library(robustbase)
    args <- commandArgs(trailingOnly = TRUE)
    arr <- as.numeric(args)
    options(mc_doScale_quiet=TRUE)
    result <- mc(arr)
    cat(sprintf("%.10f", result))
    """
  end

  @doc """
  Runs R script to calculate `medcouple/1` for indexth matrix row.

  ## Examples
      iex> Statistex.Robust.medcouple([[1],[1],[1],[1],[1],[1]], 0)
      0.0
  """
  def medcouple(matrix, index) do
    matrix
    |> Enum.map(fn x -> Enum.at(x, index) end)
    |> medcouple
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
  def adjusted_box(arr) do
    sorted = Enum.sort(arr)
    %{25 => fqr, 75 => tqr} = Statistex.percentiles(sorted, [25, 75])
    iqr = tqr - fqr
    med = medcouple(sorted)

    tolerance = fn par -> 1.5 * iqr * :math.exp(par * med) end

    lower_bound = fqr - tolerance.(if med >= 0, do: -4, else: -3)
    upper_bound = tqr + tolerance.(if med >= 0, do: 3, else: 4)

    {lower_bound, upper_bound}
  end

  @doc """
  Runs R script to calculate `adjusted_box/1` for indexth matrix row (https://en.wikipedia.org/wiki/Box_plot).

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
  Estimates range using `z_score/2` for index'th row of a matrix.

  ## Examples
      iex> Statistex.Robust.z_score([[39.0157], [50.9985], [45.1634], [63.6410], [48.1637], [54.4420], [56.6881], [49.0387], [51.9994], [45.2520]], 3,0)
      {29.837277543944065, 71.04322245605594}
  """
  def z_score(matrix, threshold, index) do
    matrix
    |> Enum.map(fn x -> Enum.at(x, index) end)
    |> z_score(threshold)
  end

  @doc """
  Estimates range using Median Absolute Deviation (MAD).

  ## Examples
      iex> Statistex.Robust.mad([1, 2, 3, 4, 5, 6, 7], 3)
      {-2.0, 10.0}

      iex> Statistex.Robust.mad([10, 15, 20, 30, 50], 2)
      {0.0, 40.0}
  """
  def mad(arr, threshold \\ 3) do
    med = Statistex.median(arr)
    mad = arr |> Enum.map(&abs(&1 - med)) |> Statistex.median()
    {med - threshold * mad, med + threshold * mad}
  end

  @doc """
  Estimates range using `mad/2` for a specified column (index) of a matrix.

  ## Examples
      iex> Statistex.Robust.mad([[1], [2], [3], [4], [5], [6], [7]], 3, 0)
      {-2.0, 10.0}

      iex> Statistex.Robust.mad([[10], [15], [20], [30], [50]], 4, 0)
      {-20.0, 60.0}
  """
  def mad(matrix, threshold, index) do
    Enum.map(matrix, fn x -> Enum.at(x, index) end) |> mad(threshold)
  end

  @doc """
  Calculates an asymmetric interval around the median using a modified version
  of the MAD for skewed data by separating positive and negative deviations from the median.

  ## Examples

      iex> Statistex.Robust.mad_skew([1, 2, 3, 4, 5, 6, 7], 3)
      {-0.5, 8.5}

      iex> Statistex.Robust.mad_skew([10, 15, 20, 30, 50], 4)
      {0.0, 60.0}
  """
  def mad_skew(arr, threshold \\ 3) do
    med = Statistex.median(arr)
    diff = arr |> Enum.map(&(&1 - med))
    neg = diff |> Enum.filter(&(&1 <= 0)) |> Statistex.median()
    pos = diff |> Enum.filter(&(&1 >= 0)) |> Statistex.median()

    {med + threshold * neg, med + threshold * pos}
  end

  @doc """
  Estimates range using `mad_skew/2` for a specified column (index) of a matrix.

  ## Examples
      iex> Statistex.Robust.mad_skew([[1], [2], [3], [4], [5], [6], [7]], 3, 0)
      {-0.5, 8.5}

      iex> Statistex.Robust.mad_skew([[10], [15], [20], [30], [50]], 2, 0)
      {10.0, 40.0}
  """
  def mad_skew(matrix, threshold, index) do
    matrix
    |> Enum.map(fn row -> Enum.at(row, index) end)
    |> mad_skew(threshold)
  end
end
