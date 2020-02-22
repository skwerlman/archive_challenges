defmodule ArchiveChallenges.MixProject do
  @moduledoc """
  This file describes, for the benefit of mix,
  how to build and run our project.

  We use it to define what we depend on, where our entry point is,
  and versioning info for our project.

  We can also configure our development tools here.
  """
  use Mix.Project

  @version "0.1.0"
  @repo "https://github.com/skwerlman/archive_challenges"

  def project do
    [
      app: :archive_challenges,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # jason is a JSON library we use to load data
      {:jason, "~> 1.1"},
      # stream_data provides tools to do property testing
      {:stream_data, "~> 0.4", only: [:dev, :test]},
      # credo is a linter and style guide enforcement tool
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      # dialyxir is an elixir frontend for erlang's dialyzer
      # it's a very powerful static analyzer
      {:dialyxir, "~>1.0.0-rc.7", only: [:dev, :test], runtime: false},
      # ex_doc builds very nice html docs from the code
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @repo,
      extras: [
        "README.md": [title: "README"]
      ]
    ]
  end

  # Various settings for dialyxir and dialyzer
  defp dialyzer do
    plt =
      case Mix.env() do
        # this fixes a failure when dialyxir is run in a test env
        :test ->
          [:ex_unit]

        _ ->
          []
      end

    [
      plt_add_apps: plt,
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions,
        :no_opaque,
        :underspecs
      ]
    ]
  end
end
