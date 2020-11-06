defmodule Generators do
  @moduledoc """
  Generates lists of numbers and compares their bits.
  """

  import Bitwise

  @a_factor 16807
  @b_factor 48271

  @doc """
  Judges the two lists of generations given start values of each generator,
  as well as the size of the list (how many generations to run).
  All values should be integers.

  ## Examples

      iex> Generators.judge_all(65, 8921, 5)
      1

  """
  def judge_all(a_start, b_start, size) do
    judge(a_gen(a_start, size, []),
          b_gen(b_start, size, []),
          0)
  end

  @doc """
  Judges the two lists of generations given start values and size.
  These generations are more selective, only using multiples of 4
  for generator A and 8 for generator B.

  ## Examples

      iex> Generators.judge_multiples(65, 8921, 5)
      0

  """
  def judge_multiples(a_start, b_start, size) do
    judge(a_gen_mult(a_start, size, 4, []),
          b_gen_mult(b_start, size, 8, []),
          0)
  end

  # Generator function for part 1 (judge_all)
  defp a_gen(_start, 0, output), do: output
  defp a_gen(start, size, output) do
    next = rem(start * @a_factor, 2147483647)
    a_gen(next, size - 1, [next | output])
  end

  # Generator function for part 2 (judge_multiples)
  defp a_gen_mult(_start, 0, _multiple, output), do: output
  defp a_gen_mult(start, size, multiple, output) do
    next = rem(start * @a_factor, 2147483647)
    if rem(next, multiple) == 0 do
      a_gen_mult(next, size - 1, multiple, [next | output])
    else
      a_gen_mult(next, size, multiple, output)
    end
  end

  # Generator function for part 1 (judge_all)
  defp b_gen(_start, 0, output) do 
    output
  end
  defp b_gen(start, size, output) do
    next = rem(start * @b_factor, 2147483647)
    b_gen(next, size - 1, [next | output])
  end

  # Generator function for part 2 (judge_multiples)
  defp b_gen_mult(_start, 0, _multiple, output), do: output
  defp b_gen_mult(start, size, multiple, output) do
    next = rem(start * @b_factor, 2147483647)
    if rem(next, multiple) == 0 do
      b_gen_mult(next, size - 1, multiple, [next | output])
    else
      b_gen_mult(next, size, multiple, output)
    end
  end

  # Counts the matches
  defp judge([], [], count), do: count
  defp judge([a | a_t], [b | b_t], count) do
    if bits_match?(a, b) do
      judge(a_t, b_t, count + 1)
    else
      judge(a_t, b_t, count)
    end
  end
 
  # Compare only the lower 16 bits
  defp bits_match?(a, b) do
    (a &&& 65535) == (b &&& 65535)
  end
end
