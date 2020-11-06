defmodule Tubes do
  @moduledoc """
  Simulates a packet traveling along a path.
  """

  @doc """
  Runs the given path to the end and returns the state.

  ## Examples

      Tubes.main("input.txt")

  """
  def main(filename) do
    grid = File.read!(filename)
    |> String.split("\n")
    |> make_grid

    %{grid: grid,
      pos: find_start_pos(grid),
      dir: "south",
      steps: 1,
      letters: ""}
    |> run
  end

  defp run(state) do
    new_pos = find_new_pos(state.pos, state.dir)

    case Map.get(state.grid, new_pos) do
      "|" ->
        state |> move_forward(new_pos) |> run
      "+" ->
        state |> find_path(new_pos) |> move_forward(new_pos) |> run
      "-" ->
        state |> move_forward(new_pos) |> run
      " " ->
        state
      letter ->
        state |> move_forward(new_pos) |> add_letter(letter) |> run
    end
  end

  defp find_new_pos({row, col}, dir) do
    case dir do
      "south" -> {row + 1, col}
      "north" -> {row - 1, col}
      "east" -> {row, col + 1}
      "west" -> {row, col - 1}
    end
  end

  defp move_forward(state, new_pos) do
    state
    |> Map.put(:pos, new_pos)
    |> Map.update!(:steps, &(&1 + 1))
  end

  defp find_path(state, new_pos) do
    new_dir = find_dir_at_fork(state.grid, state.dir, new_pos)
    Map.put(state, :dir, new_dir)
  end

  defp find_dir_at_fork(grid, dir, {row, col}) do
    case dir do
      n when n in ["north", "south"] ->
        if grid[{row, col + 1}] == " " do
          "west"
        else
          "east"
        end
      n when n in ["east", "west"] ->
        if grid[{row + 1, col}] == " " do
          "north"
        else
          "south"
        end
    end
  end

  defp add_letter(state, letter) do
    Map.update!(state, :letters, &(&1 <> letter))
  end

  defp make_grid(list_of_lines, grid \\ %{}, row \\ 0)
  defp make_grid([], grid, _row), do: grid
  defp make_grid([h | t], grid, row) do
    make_grid(t,
              add_single_row(String.graphemes(h), grid, row),
              row + 1)
  end

  defp add_single_row(line, grid, row_num, col \\ 0)
  defp add_single_row([], grid, _row_num, _col), do: grid
  defp add_single_row([h | t], grid, row_num, col) do
    add_single_row(t,
                   Map.put(grid, {row_num, col}, h),
                   row_num,
                   col + 1)
  end

  defp find_start_pos(grid, col \\ 0) do
    case grid[{0, col}] do
      "|" -> {0, col}
      _ -> find_start_pos(grid, col + 1)
    end
  end
end
