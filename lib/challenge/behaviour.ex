defmodule ArchiveChallenges.Challenge.Behaviour do
  @moduledoc """
  Defines a common API for challenge solutions
  """

  @callback run_challenge() :: :ok
  @callback run_challenge_manual([any]) :: boolean
end
