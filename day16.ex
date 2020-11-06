defmodule Dance do
  @moduledoc """
  Documentation for `Dance`.
  """

  @doc """
  Hello world.

  ## Examples

      Dance.result(input)

  """
  def result(filename, start) do
    File.read!(filename)
    |> String.trim
    |> String.split(",")
    |> Enum.reduce(start,
                   &move/2)
  end

  def part2_is_dumb(_filename, "abcdefghijklmnop", count), do: count
  def part2_is_dumb(filename, start, count) do
    part2_is_dumb(filename,
                  result(filename, start),
                  count + 1)
  end

  def stupid(filename, start \\ "abcdefghijklmnop", count \\ 40)
  def stupid(_filename, start, 0), do: start
  def stupid(filename, start, count) do
    stupid(filename,
           result(filename, start),
           count - 1)
  end
 
  defp move(x, acc) do
    <<command::binary-size(1), rest::binary>> = x
    case command do
      "s" ->
        spin(acc, String.to_integer(rest))
      "x" ->
        exchange(acc, rest)
      "p" ->
        partner(acc, rest)
    end
  end

  defp spin(order, size) do
    head_size = 16 - size
    <<h::binary-size(head_size), t::binary-size(size)>> = order
    t <> h
  end

  defp exchange(order, indices) do
    [idx_1, idx_2] = String.split(indices, "/")
    |> Enum.map(&String.to_integer/1)
    swap(order, String.at(order, idx_1), String.at(order, idx_2))
  end

  defp partner(order, names) do
    [name_1, name_2] = String.split(names, "/")
    swap(order, name_1, name_2)
  end

  defp swap(order, name_1, name_2) do
    order
    |> String.replace(name_1, "x")
    |> String.replace(name_2, "y")
    |> String.replace("x", name_2)
    |> String.replace("y", name_1)
  end
end
