defmodule DiskDefrag do
  @moduledoc """
  Provides functions for inspecting a binary grid 
  created with the Knot Hash algorithm.
  """

  @hex_to_bits %{"1" => "0001", "2" => "0010", "3" => "0011",
                 "4" => "0100", "5" => "0101", "6" => "0110",
                 "7" => "0111", "8" => "1000", "9" => "1001",
                 "a" => "1010", "b" => "1011", "c" => "1100",
                 "d" => "1101", "e" => "1110", "f" => "1111",
                 "0" => "0000"}

  @doc """
  Counts all used bits in the grid created with given seed.
  The seed must be a string.

  ## Examples

      DiskDefrag.bits_used("abcdefgh")

  """
  def bits_used(seed) do
    make_grid(%{}, seed, Enum.to_list(0..127))
    |> Map.values
    |> Enum.count(&(&1 == "1"))
  end

  @doc """
  Counts the number of unique regions (connected orthogonally) in
  the grid created with given seed.  The seed must be a string.

  ## Examples

      DiskDefrag.regions("abcdefgh")

  """
  def regions(seed) do
    state = make_state(seed)
    
    if Map.get(state.grid, {0, 0}) == "1" do
      scan_all(state)
    else
      cycle(state) |> scan_all
    end
  end

  # Loop function for scanning regions and finding the next region
  defp scan_all(state) do
    if state.row == 128 do
      state.region_count
    else
      state
      |> scan_region([{state.row, state.col}])
      |> cycle
      |> scan_all
    end
  end

  # Starts on a seen or "0" bit and searches for the next unseen "1"
  defp cycle(state) do
    cond do
      state.col == 128 ->
        state
        |> Map.put(:col, 0)
        |> Map.update!(:row, &(&1 + 1))
        |> cycle
      {state.row, state.col} in state.seen ->
        state
        |> Map.update!(:col, &(&1 + 1))
        |> cycle
      Map.get(state.grid, {state.row, state.col}) == "0" ->
        state
        |> Map.update!(:seen, &([{state.row, state.col} | &1]))
        |> cycle
      true ->
        state
    end
  end

  # This starts on a "1" and checks everything orthogonally
  defp scan_region(state, []), do: state |> Map.update!(:region_count, &(&1 +1))
  defp scan_region(state, [{row, col} | t]) do
    cond do
      row < 0 or row > 127 or col < 0 or col > 127 or 
      {row, col} in state.seen ->
        scan_region(state,t)
      state.grid[{row, col}] == "0" ->
        state
        |> Map.update!(:seen, &([{row, col} | &1]))
        |> scan_region(t)
      true ->
        state
        |> Map.update!(:seen, &([{row, col} | &1]))
        |> scan_region([{row+1, col} | [{row-1, col} | [{row, col+1}
                       | [{row, col-1} | t]]]])
    end
  end

  defp make_state(seed) do
    grid = make_grid(%{}, seed, Enum.to_list(0..127))

    %{grid: grid, seen: [], row: 0, col: 0, region_count: 0}
  end

  defp make_grid(acc, _seed, []), do: acc 
  defp make_grid(acc, seed, [h | t]) do
    hash_bits(seed <> "-" <> Integer.to_string(h))
    |> String.graphemes
    |> map_bits(acc, h, 0)
    |> make_grid(seed, t)
  end

  defp map_bits([], map, _row, _col), do: map
  defp map_bits([h | t], map, row, col) do
    map_bits(t,
             Map.put(map, {row, col}, h),
             row,
             col + 1)
  end

  # Gets knot hash from input string and outputs as binary
  defp hash_bits(input_string) do
    input_string
    |> KnotHash.from_string
    |> String.graphemes
    |> Enum.map(&(@hex_to_bits[&1]))
    |> List.to_string
  end
end
