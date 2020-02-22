defmodule ArchiveChallenges.Challenge.PrimalityTest do
  @moduledoc """
  Create a program which determines if a number specified by
  the user is prime or composite

  First, we perform some simple checks before doing any heavy math
  to exclude some obvious non-primes

  Next, we use Selfridge's Conjecture[1] along with the Fermat test[2]
  to exclude (probably not all) non-primes

  Finally, we perform trial division to determine if the
  number actually is prime

  [1](https://en.wikipedia.org/wiki/John_Selfridge#Selfridge's_conjecture_about_primality_testing)
  [2](Fermat test: https://en.wikipedia.org/wiki/Fermat_primality_test)
  """
  alias ArchiveChallenges.Data.PrimeLUT
  @behaviour ArchiveChallenges.Challenge.Behaviour

  @impl ArchiveChallenges.Challenge.Behaviour
  @spec run_challenge :: :ok
  def run_challenge do
    # for the autorun, we check the first million numbers,
    # printing out primes
    0..1_000_000
    |> Stream.filter(&prime?(&1))
    # |> Enum.map(fn p -> "#{p} is prime" end)
    |> Stream.map(fn p -> "#{p} is prime" end)
    |> Enum.each(&IO.puts(&1))

    :ok
  end

  @impl ArchiveChallenges.Challenge.Behaviour
  @spec run_challenge_manual([number]) :: boolean
  def run_challenge_manual([p | _]) do
    prime?(p)
  end

  # this attribute is a hack to include a constant funtion in a guard
  # because it is calculated at compile time, the guard can treat it
  # as if it were an integer
  @lut_max PrimeLUT.max()

  # this attribute provides an upper bound for a LUT-assisted
  # search. any number below this that isn't divisible by
  # anything in the LUT is prime
  @lut_max_sq @lut_max * @lut_max

  @doc """
  Checks if the given number is prime.
  """
  @spec prime?(number) :: boolean
  # this is a bodyless function head
  # see https://blog.robphoenix.com/elixir/notes-on-elixir-bodyless-functions/
  def prime?(maybe_prime)

  # some very basic checks first:
  def prime?(p) when not is_number(p), do: throw(TypeError)
  def prime?(p) when p < 2, do: false

  # if p is smaller than the largest prime in our LUT
  # we only need to check if p is in the LUT
  # because all primes less than that are in there
  def prime?(p) when p < @lut_max do
    p in PrimeLUT.lut()
  end

  # if p < lut_max^2 then we search for
  # factors in the prime lut by modulo
  # in none are found, p is prime
  def prime?(p) when p < @lut_max_sq do
    PrimeLUT.lut()
    |> Enum.find(:prime, fn m -> rem(p, m) == 0 end)
    |> case do
      :prime -> true
      _ -> false
    end
  end

  # if p < lut_max^2 then we search for
  # factors in the prime lut by modulo
  # in none are found, p is a canditate prime
  # so we move on to more expensive checks
  def prime?(p) do
    PrimeLUT.lut()
    |> Enum.find(:prime, fn m -> rem(p, m) == 0 end)
    |> case do
      :prime -> expensive_prime?(p)
      _ -> false
    end
  end

  # we set the number of fermat test workers to
  # the number of BEAM schedulers minus one
  # this decreases slowdown due to scheduler contention
  # since the total number of our spawned workers
  # (including the selfridge worker) is equal to
  # the number of schedulers
  @fermat_workers System.schedulers_online() - 1

  # the real checking starts here
  # we spawn s-1 fermat workers and
  # 1 selfridge worker for a total s workers
  # this is because the fermat test improves
  # in accuracy the more times it is run
  # we take advantage of this and the fact that
  # each round does not depend on the prior round
  # to perform more accurate checks when more power
  # is available to us without losing any speed
  # the selfridge test cannot be improved by
  # running it more than once, so we only
  # spawn one worker for it
  defp expensive_prime?(p) do
    fermat_pids =
      for _ <- 1..@fermat_workers do
        Task.async(fn -> fermat(p, 10) end)
      end

    # selfridge_pid = Task.async(fn -> selfridge(p) end)

    # [selfridge_pid | fermat_pids]
    fermat_pids
    |> Task.yield_many(:infinity)
    |> Stream.map(fn {task, res} ->
      res || Task.shutdown(task, :brutal_kill)
    end)
    |> Stream.map(fn
      {:ok, val} -> val
      # if the task died for some reason, assume it returned true
      # that way we dont reject any primes even if we error out
      {:exit, _} -> true
    end)
    |> Enum.reduce(fn ret, acc -> acc && ret end)
  end

  @spec fermat(non_neg_integer, integer) :: boolean
  def fermat(p, rounds) do
    rnds =
      p
      |> isqrt()
      |> min(rounds)
      |> max(1)

    fermat(p, rnds, true)
  end

  defp fermat(_p, _rounds, false), do: false
  defp fermat(_p, 0, true), do: true

  defp fermat(p, rounds, true) do
    a = :rand.uniform(p - 1)

    gcd? = gcd(p, a) == 1
    # we use the mod_pow nif because a recursive
    # integer exponent function impl took
    # multiple minutes for large nums
    mod? =
      case :crypto.mod_pow(a, p - 1, p) do
        <<1>> -> true
        _ -> false
      end

    fermat(p, rounds - 1, gcd? && mod?)
  end

  @spec selfridge(integer) :: boolean
  def selfridge(p) when rem(p, 2) == 0, do: false
  def selfridge(p) when rem(p, 5) != 2 and rem(p - 4, 5) != 2 do
    IO.puts("FAILED CLAUSE 2")
    IO.puts(inspect(rem(p, 5)))
    IO.puts(inspect(rem(p + 4, 5)))
    IO.puts(inspect(rem(p - 4, 5)))
    false
  end

  def selfridge(p) do
    fermat? =
      case :crypto.mod_pow(2, p - 1, p) do
        <<1>> -> true
        _ -> false
      end

    IO.puts(inspect(fermat?))

    fermat? && rem(fib(p + 1), p) == 0
  end

  # integer square root ported from erlangs crypto impl
  defp isqrt(0), do: 0
  defp isqrt(1), do: 1

  defp isqrt(x) when x >= 0 do
    r = div(x, 2)
    isqrt(div(x, r), r, x)
  end

  defp isqrt(q, r, x) when q < r do
    r1 = div(r + q, 2)
    isqrt(div(x, r1), r1, x)
  end

  defp isqrt(_q, r, _x), do: r

  # greatest common denominator
  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  # Fast Doubling Fibonacci, transliterated from haskell
  # https://www.nayuki.io/res/fast-fibonacci-algorithms/fastfibonacci.hs
  # Despite the name, it is painfully slow for big ints
  defp fib(n) do
    {res, _} = fast_fib(n)
    res
  end

  defp fast_fib(0), do: {0, 1}
  defp fast_fib(n) do
    {a, b} = fast_fib(div(n, 2))
    c = a * (b * 2 - a)
    d = a * a + b * b
    case rem(n, 2) do
      0 -> {c, d}
      _ -> {d, c + d}
    end
  end
end
