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
      package: package(),
      source_url: "https://github.com/chazzka/statistex_robust",
      docs: [
        # The main page in the generated documentation
        main: "readme",
        format: "html",
        extras: ["README.md"]
      ]
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
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chazzka/statistex_robust"},
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
      {:nimble_csv, "~> 1.1", only: :example},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false}
    ]
  end
end
