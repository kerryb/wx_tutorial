defmodule WxTutorial.MixProject do
  use Mix.Project

  def project do
    [
      app: :wx_tutorial,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :runtime_tools, :wx],
      mod: {WxTutorial.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:styler, "~> 1.0", only: [:dev, :test], runtime: false},
      {:wx_ex, "~> 0.4.2", runtime: false}
    ]
  end
end
