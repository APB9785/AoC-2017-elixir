defmodule Sporifica do
  @moduledoc """
  Runs a cellular automata (Langston's Ant) given an initial configuration.
  There are two states: "clean" (.) and "infected" (#)
  """

  @doc """
  Counts how many generations create a new "infected" cell.

  ## Examples

      Sporifica.part_one("input.txt", 10000)

  """
  def part_one(filename, gen_limit) do
    config = File.read!(filename)
    |> String.trim
    |> String.split("\n")

    idx = length(config) |> div(2)

    init_grid = config
    |> Enum.map(&String.graphemes/1)
    |> make_grid(-idx, idx, idx, %{})

    run_p1(init_grid, "N", {0, 0}, gen_limit, 0)
  end

  defp run_p1(_, _, _, 0, infect_count), do: infect_count
  defp run_p1(grid, dir, pos, gens_left, infect_count) do
    if grid[pos] == "#" do
      new_dir = turn_right(dir)
      new_grid = Map.put(grid, pos, ".")
      new_pos = step_forward(pos, new_dir)

      run_p1(new_grid, new_dir, new_pos, gens_left - 1, infect_count)
    else
      new_dir = turn_left(dir)
      new_grid = Map.put(grid, pos, "#")
      new_pos = step_forward(pos, new_dir)

      run_p1(new_grid, new_dir, new_pos, gens_left - 1, infect_count + 1)
    end
  end

  def part_two(filename, gen_limit) do
    config = File.read!(filename)
    |> String.trim
    |> String.split("\n")

    idx = length(config) |> div(2)

    init_grid = config
    |> Enum.map(&String.graphemes/1)
    |> make_grid(-idx, idx, idx, %{})

    run_p2(init_grid, "N", {0, 0}, gen_limit, 0)
  end

  defp run_p2(_, _, _, 0, infect_count), do: infect_count
  defp run_p2(grid, dir, pos, gens_left, infect_count) do
    case grid[pos] do
      nil ->
        new_dir = turn_left(dir)
        new_grid = Map.put(grid, pos, "W")
        new_pos = step_forward(pos, new_dir)

        run_p2(new_grid, new_dir, new_pos, gens_left - 1, infect_count)
      "." ->
        new_dir = turn_left(dir)
        new_grid = Map.put(grid, pos, "W")
        new_pos = step_forward(pos, new_dir)

        run_p2(new_grid, new_dir, new_pos, gens_left - 1, infect_count)
      "#" ->
        new_dir = turn_right(dir)
        new_grid = Map.put(grid, pos, "F")
        new_pos = step_forward(pos, new_dir)

        run_p2(new_grid, new_dir, new_pos, gens_left - 1, infect_count)
      "W" ->
        new_grid = Map.put(grid, pos, "#")
        new_pos = step_forward(pos, dir)

        run_p2(new_grid, dir, new_pos, gens_left - 1, infect_count + 1)
      "F" ->
        new_dir = turn_around(dir)
        new_grid = Map.put(grid, pos, ".")
        new_pos = step_forward(pos, new_dir)

        run_p2(new_grid, new_dir, new_pos, gens_left - 1, infect_count)
    end
  end

  defp turn_left(dir) do
    case dir do
      "N" -> "W"
      "E" -> "N"
      "S" -> "E"
      "W" -> "S"
    end
  end

  defp turn_right(dir) do
    case dir do
      "N" -> "E"
      "E" -> "S"
      "S" -> "W"
      "W" -> "N"
    end
  end

  defp turn_around(dir) do
    case dir do
      "N" -> "S"
      "E" -> "W"
      "S" -> "N"
      "W" -> "E"
    end
  end

  defp step_forward({x, y}, dir) do
    case dir do
      "N" -> {x, y + 1}
      "E" -> {x + 1, y}
      "S" -> {x, y - 1}
      "W" -> {x - 1, y}
    end
  end

  defp make_grid([[] | []], _, _, _, acc), do: acc
  defp make_grid([[] | rest], _x, y, max, acc) do
    make_grid(rest, -max, y - 1, max, acc)
  end
  defp make_grid([[h | t] | rest], x, y, max, acc) do
    make_grid([t | rest], x + 1, y, max, Map.put(acc, {x, y}, h))
  end
end
