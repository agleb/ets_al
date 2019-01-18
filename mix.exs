defmodule EtsAl.MixProject do
  use Mix.Project

  def project do
    [
      app: :ets_al,
      version: "0.1.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      deps: deps(),
      name: "ets_al",
      source_url: "https://github.com/agleb/ets_al"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EtsAl.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:forensic, "~> 0.1.0"}
    ]
  end

  defp description() do
    "A macro for descriptive error reporting."
  end

  defp package() do
    [
      name: "ets_al",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Gleb Andreev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/agleb/ets_al"}
    ]
  end
end
