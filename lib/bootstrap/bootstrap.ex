defmodule Statistex.Robust.Bootstrap do
  @moduledoc """
  Provides a method for estimating the original data range from a sample
  using bootstrapping with extrapolation. This approach generates resampled
  data, calculates the min and max values for each resample, and applies a
  percentage-based extrapolation to estimate a wider range than the sample
  might initially suggest.

  ## Example

      iex> data = [57, 57, 57, 58, 63, 66, 66, 67, 67, 68, 69, 70, 70, 70, 70, 72,
      ...>         73, 75, 75, 76, 76, 78, 79, 81]
      iex> n_resamples = 1000
      iex> extrapolation_percentage = 0.10
      iex> Statistex.Robust.Bootstrap.extrapolate(data, n_resamples, extrapolation_percentage)
      {51.3, 89.1}

  """

  @doc """
  Performs bootstrapping with extrapolation to estimate a wider range for the
  original data based on the provided sample.

  - `data`: A list of numbers representing the sample data.
  - `n_resamples`: The number of bootstrap resamples to generate.
  - `extrapolation_percentage`: The percentage of extrapolation to apply
    on the lower and upper bounds.

  Returns a tuple `{extended_min, extended_max}` representing the estimated
  range with extrapolation applied.
  """
  def extrapolate(data, n_resamples, extrapolation_percentage) do
    {bootstrap_mins, bootstrap_maxs} =
      1..n_resamples
      |> Enum.map(fn _ ->
        resample = Enum.map(1..length(data), fn _ -> Enum.random(data) end)
        {Enum.min(resample), Enum.max(resample)}
      end)
      |> Enum.unzip()

    %{1 => left_bound_min, 99 => _} = Statistex.percentiles(bootstrap_mins, [1, 99])
    %{1 => _, 99 => right_bound_max} = Statistex.percentiles(bootstrap_maxs, [1, 99])

    extended_min = left_bound_min - extrapolation_percentage * abs(left_bound_min)
    extended_max = right_bound_max + extrapolation_percentage * abs(right_bound_max)

    {extended_min, extended_max}
  end

  @doc """
    Estimates range using `extrapolate/3` for a specified column (index) of a matrix.

  """
  def extrapolate(matrix, n_resamples, extrapolation_percentage, index) do
    matrix
    |> Enum.map(fn row -> Enum.at(row, index) end)
    |> extrapolate(n_resamples, extrapolation_percentage)
  end
end
