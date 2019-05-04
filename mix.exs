defmodule Huffman.MixProject do
  use Mix.Project
  @moduledoc false

  def project do
    [
      app: :huffman,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.11.0", only: [:test]},
      {:typed_struct, "~> 0.1.4"}
    ]
  end
end
