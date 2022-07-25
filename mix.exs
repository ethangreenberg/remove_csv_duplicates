defmodule RemoveCSVDuplicates.MixProject do
  use Mix.Project

  def project do
    [
      app: :remove_csv_duplicates,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_phone_number, "~> 0.3"},
      {:nimble_csv, "~> 1.1"}
    ]
  end
end
