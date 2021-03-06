defmodule AutoProcessRegistry.Mixfile do
  use Mix.Project

  def project do
    [app: :auto_process_registry,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Docs
     description: "A simple process registry that can instantiate new processes on the fly",
     package: [
      name: :auto_process_registry,
      maintainers: ["Cees de Groot"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/cdegroot/auto_process_registry"}
     ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:dialyxir, "~> 0.3.5", only: [:dev]},
     {:ex_doc, "~> 0.14", only: :dev}]
  end
end
