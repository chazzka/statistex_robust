# Require csv_loader since only lib modules are required automatically
Code.require_file("csv_loader/csv_loader.ex", __DIR__)

# Optional: write your parser function to parse csv data
parse_value = fn string ->
  case String.contains?(string, ".") do
    true -> String.to_float(string)
    false -> String.to_integer(string)
  end
end

# First you may want to load your csv
rows =
  Example.CSVLoader.load_csv(
    "example/data/Banknote_Authentication.csv",
    fn row -> Enum.map(row, fn val -> parse_value.(val) end) end
  )
  |> IO.inspect()

# We calculate minmax for comparison
Statistex.Robust.minmax(rows, 0)
|> IO.inspect()

# Then we calculate the robust statistics for each dimension (column) of the given dataset

Statistex.Robust.adjusted_box(rows, 0)
|> IO.inspect()

Statistex.Robust.z_score(rows, 3, 0)
|> IO.inspect()

Statistex.Robust.mad(rows, 3, 0)
|> IO.inspect()

Statistex.Robust.mad_skew(rows, 3, 0)
|> IO.inspect()

Statistex.Robust.Bootstrap.extrapolate(rows, 100, 0.5, 0)
|> IO.inspect()
