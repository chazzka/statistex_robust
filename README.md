
# Statistex.Robust

Statistex.Robust provides robust, range-based statistical methods built on top of the [Statistex](https://hexdocs.pm/statistex/readme.html) library.

Github repo: https://github.com/chazzka/statistex_robust


## Installation

The package can be installed
by adding `statistex_robust` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:statistex_robust, "~> 0.1.0"}
  ]
end
```

## Quickstart
For quickstart please refer to the `test` folder for simple examples or to the `example` folder for more robust examples on larger datasets.

Run with:
```
$ MIX_ENV=example mix run example/example_bootstrap.ex
```

## Methods

### `medcouple/1`
Calculates the medcouple, a robust statistic that measures skewness in a univariate distribution. Requires `Rscript` to be available in the shell path.

```elixir
iex> Statistex.Robust.medcouple([1, 1, 1, 1, 1, 1])
0.0

iex> Statistex.Robust.medcouple([0, 2, 2, 2, 2, 5, 10])
0.4
```

### `medcouple/2`
Calculates the medcouple for a specific column in a matrix.

```elixir
iex> Statistex.Robust.medcouple([[1], [1], [1], [1], [1], [1]], 0)
0.0
```

### `adjusted_box/1`
Calculates the adjusted boxplot bounds for a univariate dataset, considering the medcouple for skewness. Requires `medcouple`.

```elixir
iex> Statistex.Robust.adjusted_box([1, 1, 1, 1, 1, 1])
{1.0, 1.0}

iex> Statistex.Robust.adjusted_box([0, 1, 2, 3, 4, 5])
{-4.5, 9.5}
```

### `adjusted_box/2`
Calculates the adjusted boxplot bounds for a specified column (index) of a matrix.

```elixir
iex> Statistex.Robust.adjusted_box([[1], [1], [1], [1], [1], [1]], 0)
{1.0, 1.0}
```

### `z_score/2`
Estimates the range using Z-score for a univariate dataset.

```elixir
iex> Statistex.Robust.z_score([39.0157, 50.9985, 45.1634, 63.6410, 48.1637, 54.4420, 56.6881, 49.0387, 51.9994, 45.2520], 3)
{29.837277543944065, 71.04322245605594}
```

### `z_score/3`
Estimates the range using Z-score for a specified column (index) in a matrix.

```elixir
iex> Statistex.Robust.z_score([[39.0157], [50.9985], [45.1634], [63.6410], [48.1637], [54.4420], [56.6881], [49.0387], [51.9994], [45.2520]], 3, 0)
{29.837277543944065, 71.04322245605594}
```

### `mad/2`
Estimates range using the Median Absolute Deviation (MAD) for a univariate dataset.

```elixir
iex> Statistex.Robust.mad([1, 2, 3, 4, 5, 6, 7], 3)
{-2.0, 10.0}

iex> Statistex.Robust.mad([10, 15, 20, 30, 50], 2)
{0.0, 40.0}
```

### `mad/3`
Estimates range using the MAD for a specified column (index) in a matrix.

```elixir
iex> Statistex.Robust.mad([[1], [2], [3], [4], [5], [6], [7]], 3, 0)
{-2.0, 10.0}

iex> Statistex.Robust.mad([[10], [15], [20], [30], [50]], 4, 0)
{-20.0, 60.0}
```

### `mad_skew/2`
Calculates an asymmetric interval around the median using a skew-adjusted MAD.

```elixir
iex> Statistex.Robust.mad_skew([1, 2, 3, 4, 5, 6, 7], 3)
{-0.5, 8.5}

iex> Statistex.Robust.mad_skew([10, 15, 20, 30, 50], 4)
{0.0, 60.0}
```

### `mad_skew/3`
Calculates an asymmetric interval around the median using skew-adjusted MAD for a specific column (index) in a matrix.

```elixir
iex> Statistex.Robust.mad_skew([[1], [2], [3], [4], [5], [6], [7]], 3, 0)
{-0.5, 8.5}

iex> Statistex.Robust.mad_skew([[10], [15], [20], [30], [50]], 2, 0)
{10.0, 40.0}
```

### `minmax/2`
Calculates the minimum and maximum values for a specific column in a matrix.

```elixir
iex> Statistex.Robust.minmax([[1, 2, 3], [4, 5, 6], [7, 8, 9]], 0)
{1, 7}

iex> Statistex.Robust.minmax([[10, 20], [5, 15], [25, 30]], 1)
{15, 30}
```

---

# Statistex.Robust.Bootstrap

Provides a method for estimating the original data range from a sample using bootstrapping with extrapolation. This approach generates resampled data, calculates the min and max values for each resample, and applies a percentage-based extrapolation to estimate a wider range.

### `extrapolate/3`
Performs bootstrapping with extrapolation to estimate a wider range for the original data based on the provided sample.

```elixir
iex> data = [57, 57, 57, 58, 63, 66, 66, 67, 67, 68, 69, 70, 70, 70, 70, 72, 73, 75, 75, 76, 76, 78, 79, 81]
iex> n_resamples = 1000
iex> extrapolation_percentage = 0.10
iex> Statistex.Robust.Bootstrap.extrapolate(data, n_resamples, extrapolation_percentage)
{51.3, 89.1}
```

### `extrapolate/4`
Estimates range using `extrapolate/3` for a specified column (index) of a matrix.

```elixir
iex> data = [[57], [58], [63], [66], [67], [68], [69], [70], [72], [73], [75], [76], [78], [79], [81]]
iex> Statistex.Robust.Bootstrap.extrapolate(data, 1000, 0.10, 0)
{51.3, 89.1}
```

The docs can be found at <https://hexdocs.pm/statistex_robust>.
