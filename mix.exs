defmodule StuartClientElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :stuart_client_elixir,
      description: "Stuart API Elixir client",
      package: %{
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/StuartApp/stuart-client-elixir"
        }
      },
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
      {:httpoison, "~> 1.3.1"},
      {:oauth2, "~> 0.9.3"},
      {:jason, "~> 1.1.1"},
      {:cachex, "~> 3.0.3"},
      {:mox, "~> 0.4.0", only: :test},
      {:mock, "~> 0.3.2", only: :test}
    ]
  end
end
