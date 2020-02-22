# ArchiveChallenges
A collection of challenge solutions for the Dark Archives server

I have tried to document everything as best I can
so the solutions can serve as a tutorial of sorts

If something doesn't make sense (or work lol)
open an issue about it

## Setup

First install the following:
- Elixir ~> 1.10: https://elixir-lang.org/install.html
- Erlang/OTP ~> 22.2: https://www.erlang.org/downloads

Once you have those installed, make sure `mix` is on your path, then run
`mix deps.get` to install all the dependencies

## Compiling

`mix compile`

## Running the challenges

Run `iex -S mix` to load into the interactive Elixir shell.

At the prompt, run `ArchiveChallenges.Challenge.<challenge module name>.run_challenge()` to run through the challenge automatically.

Run `ArchiveChallenges.Challenge.<challenge module name>.run_challenge_manual([<comma separated args>])` to run the challenge with supplied input.

I plan on writing Mix tasks for these at some point to make this easier.

## Running the tests

NOTE: tests arent written yet

`mix test`

The tests are a mix of standard unit tests, doc tests, and more
thorough property tests

The unit tests and doc tests should run failry quickly, but the property
tests can take a while. You can tune how long they take by editing
`config/prop_tests.config.exs`, following the docs for
[stream_data](https://hexdocs.pm/stream_data/ExUnitProperties.html#check/1-options)

## Linting the source code

We use two different linting/analysis tools in this project: Credo and Dialyxir

Credo is a traditional linter and style tool, and can be run with `mix credo --strict`

Dialyxir is an Elixir frontend for OTP's native `:dialyzer` tool. It
performs static analysis and type checking, and can be run with
`mix dialyzer`

## Documentation

HTML documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) by running `mix docs`
