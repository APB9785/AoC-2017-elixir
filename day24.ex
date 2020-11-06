defmodule MoatBridge do
  @moduledoc """
  Documentation for `MoatBridge`.
  """

  @doc """
  Hello world.

  ## Examples

      MoatBridge.main("input.txt")

  """
  def main(filename) do
    File.read!(filename)
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> start
    |> build
    |> results
  end

  def start(list_of_lists, found \\ [], discarded \\ [])
  def start([], found, _), do: found
  def start([[a, b] | t], found, discarded) do
    cond do
      a == 0 ->
        node = %{endpoint: b, inv: t ++ discarded, length: 1, strength: b}
        start(t, [node | found], [[a, b] | discarded])
      b == 0 ->
        node = %{endpoint: a, inv: t ++ discarded, length: 1, strength: a}
        start(t, [node | found], [[a, b] | discarded])
      true ->
        start(t, found, [[a, b] | discarded])
    end
  end

  def build(current, next_tier \\ [], done \\ [])
  def build([], [], done), do: done
  def build([], next_tier, done), do: build(next_tier, [], done)
  def build([node | rest], next_tier, done) do
    case search(node.inv, node.endpoint) do
      [] ->
        build(rest, next_tier, [node | done])
      matches ->
        build(rest, next_tier ++ add_next(node, matches), done)
    end
  end

  # Pieces are lists of length 2, returns list of pieces
  defp search(list, target, found \\ [])
  defp search([], _, found), do: found
  defp search([[a, b] | t], target, found) do
    if a == target or b == target do
        search(t, target, [[a, b] | found])
    else
        search(t, target, found)
    end
  end

  # Pieces are lists of length 2, returns list of new nodes
  defp add_next(root, list_of_pieces, done \\ [])
  defp add_next(_, [], done), do: done
  defp add_next(root, [[a, b] | t], done) do
    [new_endp] = List.delete([a, b], root.endpoint)

    new_node = root
    |> Map.update!(:strength, &(&1 + a + b))
    |> Map.put(:endpoint, new_endp)
    |> Map.update!(:length, &(&1 + 1))
    |> Map.update!(:inv, &List.delete(&1, [a, b]))

    add_next(root, t, [new_node | done])
  end

  defp parse_line(str) do
    str |> String.split("/") |> Enum.map(&String.to_integer/1)
  end

  defp results(state) do
    part_1 = Enum.max_by(state, fn node -> node.strength end)
    part_2 = Enum.max_by(state,
                         fn node -> node.length * 10000 + node.strength end)
    "Part 1: " <> Integer.to_string(part_1.strength) <> "  //  " <>
    "Part 2: " <> Integer.to_string(part_2.strength)
  end
end
