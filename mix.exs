defmodule ElixirChat.Mixfile do
  use Mix.Project

  def project do
   [
     app: :elixir_chat,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps,
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
   ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {ElixirChat, []},
     applications: [:phoenix, :cowboy, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
     {:phoenix, github: "phoenixframework/phoenix", ref: "180ebe64738c24aa7b47a74f06a3feac41a284e5", override: true},
     {:phoenix_live_reload, github: "phoenixframework/phoenix_live_reload"},
     {:phoenix_html, "~> 1.1"},
     {:cowlib,  "1.0.0"},
     {:cowboy,  "~> 1.0"},
     {:poolboy, "~> 1.5.1", optional: true},
     {:eredis, github: "wooga/eredis", optional: true},
     {:uuid,    "~> 0.1.5" },
     {:exactor, "~> 2.0.0" },
     {:exrm, "~> 0.14.16"},
      ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]
end
