defmodule Fractal do
  @moduledoc """
  Enlarges a 3x3 array of pixels according to a given set of rules.
  """

  @initial_state ".#./..#/###"
  #@initial_state "....../######/....../######/....../######"

  @doc """
  Runs the process given a rules file and number of iterations to run.

  ## Examples

      Fractal.main("input.txt", 2)

  """
  def main(filename, iterations) do
    rules_map = File.read!(filename)
    |> String.trim
    |> String.split("\n", trim: true)
    |> parse_rules

    run(@initial_state, rules_map, iterations)
  end

  def count_pixels(long_string) do
    long_string
    |> String.graphemes
    |> Enum.count(fn x -> x == "#" end)
  end

  def run(state, _rules, 0), do: state
  def run(state, rules, iterations) do
    size = state |> String.split("/") |> hd |> String.length
    if rem(size, 2) == 0 do
      String.split(state, "/")
      |> Enum.map(&split_every(&1, 2))
      |> chunk(2)
      |> Enum.map(&Map.get(rules, &1))
      |> merge_all
      |> Enum.join("/")
      |> run(rules, iterations - 1)
    else
      String.split(state, "/")
      |> Enum.map(&split_every(&1, 3))
      |> chunk(3)
      |> Enum.map(&Map.get(rules, &1))
      |> merge_all
      |> Enum.join("/")
      |> run(rules, iterations - 1)
    end
  end

  def chunk(state, size, acc \\ [])
  def chunk([], _, acc), do: acc
  def chunk([top_row | [bot_row | rest]], 2, acc) do
    new_chunks = Enum.zip(top_row, bot_row)
    |> Enum.map(&tuple_to_str/1)

    chunk(rest, 2, acc ++ new_chunks)
  end

  def chunk([top_row | [mid_row | [bot_row | rest]]], 3, acc) do
    new_chunks = Enum.zip([top_row, mid_row, bot_row])
    |> Enum.map(&tuple_to_str/1)

    chunk(rest, 3, acc ++ new_chunks)
  end

  def tuple_to_str({top, bot}), do: top <> "/" <> bot
  def tuple_to_str({top, mid, bot}), do: top <> "/" <> mid <> "/" <> bot

  def merge_all(state) do
    r = length(state) |> :math.sqrt |> round
    merge_all(state, r, [])
  end

  def merge_all([], _, acc), do: acc
  def merge_all(state, size, acc) do
    {curr, rest} = Enum.split(state, size)
    merge_all(rest, size, acc ++ single_join(curr))
  end

  def single_join(list) do
    list
    |> Enum.map(&String.split(&1, "/"))
    |> transpose
    |> Enum.map(&Enum.join(&1))
  end

  defp split_every(str, size) do
    String.graphemes(str)
    |> Enum.chunk_every(size)
    |> Enum.map(&Enum.join/1)
  end

  defp parse_rules(rule_list, acc \\ %{})
  defp parse_rules([], acc), do: acc
  defp parse_rules([h | t], acc) do
    [_, k, v] = Regex.run(~r{([\S]+) => ([\S]+)}, h)

    k_f = flip(k)
    k_90 = rotate(k)
    k_90_f = flip(k_90)
    k_180 = rotate(k_90)
    k_180_f = flip(k_180)
    k_270 = rotate(k_180)
    k_270_f = flip(k_270)

    new_acc = acc
    |> Map.put_new(k, v)
    |> Map.put_new(k_f, v)
    |> Map.put_new(k_90, v)
    |> Map.put_new(k_90_f, v)
    |> Map.put_new(k_180, v)
    |> Map.put_new(k_180_f, v)
    |> Map.put_new(k_270, v)
    |> Map.put_new(k_270_f, v)

    parse_rules(t, new_acc)
  end

  defp flip(str_input) do
    str_input
    |> split
    |> Enum.reverse
    |> unsplit
  end

  defp rotate(str_input) do
    str_input
    |> split
    |> transpose
    |> Enum.map(&Enum.reverse/1)
    |> unsplit
  end

  # Turns a string into a list of lists
  defp split(str) do
    str
    |> String.split("/")
    |> Enum.map(&String.graphemes/1)
  end

  # Turns the list of lists back into a string
  defp unsplit(list_of_lists) do
    list_of_lists
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("/")
  end

  defp transpose(list_of_lists) do
    list_of_lists
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end
