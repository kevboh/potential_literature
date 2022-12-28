defmodule PotentialLiterature.MixProject do
  use Mix.Project

  def project do
    [
      app: :potential_literature,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PotentialLiterature.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.6"},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.0"},
      # https://github.com/Kraigie/nostrum/issues/424
      {:cowlib, "~> 2.11", hex: :remedy_cowlib, override: true},
      {:tz, "~> 0.24.0"}
    ]
  end
end
