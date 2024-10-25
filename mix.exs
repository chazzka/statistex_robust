defmodule StatistexRobust.MixProject do
  use Mix.Project

  def project do
    [
      app: :statistex_robust,
      description: "Robust statistics based on Statistex library",
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specify which files are to be included in final package
  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README.md"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:statistex, "~> 1.0"},

      # dependencies for `examples` env
      {:nimble_csv, "~> 1.1", only: :example}
    ]
  end
end
