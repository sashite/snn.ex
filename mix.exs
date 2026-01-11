defmodule Sashite.Snn.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/sashite/snn.ex"

  def project do
    [
      app: :sashite_snn,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "Sashite.Snn",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    SNN (Style Name Notation) implementation for Elixir.
    Provides strictly validated, human-readable names for game styles in abstract strategy games.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Sashité"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Sashité" => "https://sashite.dev",
        "Spec" => "https://sashite.dev/specs/snn/1.0.0/"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
