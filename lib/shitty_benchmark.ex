defmodule ArchiveChallenges.ShittyBenchmark do
  def measure(fun, args \\ []) do
    fun
    |> :timer.tc(args)
    |> elem(0)
    |> Kernel./(1_000_000)
  end

  # def measure_times(fun, count) do

  # end
end
