defmodule FuzzRustErlExt.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fuzz_rust_erl_ext,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:propcheck, git: "https://github.com/alfert/propcheck.git"}
    ]
  end
end
