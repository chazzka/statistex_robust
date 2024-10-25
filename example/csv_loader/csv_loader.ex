defmodule Example.CSVLoader do
  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  def load_csv(file_path, transform_function) do
    file_path
    |> File.stream!()
    |> MyParser.parse_stream(skip_headers: false)
    |> Enum.map(fn row -> transform_function.(row) end)
  end
end
