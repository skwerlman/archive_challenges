defmodule ArchiveChallenges.Data.PrimeLUT do
  @moduledoc """
  Provides a lookup table containing the first 10000 primes
  """
  @lut Jason.decode!(File.read!("priv/data/prime_lut.json"), keys: :atoms)

  @spec lut :: [2..104_729, ...]
  def lut, do: @lut.lut
  @spec max :: 104_729
  def max, do: @lut.max
  @spec mid :: 48_611
  def mid, do: @lut.mid
end
