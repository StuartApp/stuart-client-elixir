defmodule StuartClientElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :stuart_client_elixir,
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:oauth2, :httpoison, :cachex],
      mod: {StuartClientElixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:httpoison, "~> 0.13.0"},
      {:oauth2, "~> 0.9"},
      {:poison, "~> 4.0"},
      {:cachex, "~> 3.0"},
      {:mox, "~> 0.3", only: :test},
      {:mock, "~> 0.3.1", only: :test}
    ]
  end
end
