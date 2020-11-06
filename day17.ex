defmodule Spinlock do
  @moduledoc """
  Simulates a circular list which grows by inserting consecutive
  integers with a given step size.
  """

  @doc """
  Finds the list value immediately after the 2017th insertion.

  ## Examples

      Spinlock.part_one(314)

  """
  def part_one(step_size) do
    grow([0], step_size, 1)
  end

  @doc"""
  Finds the list value immediately after 0, once the list has
  inserted 50_000_000 values.

  ## Examples
  
      Spinlock.part_two(314)

  """
  def part_two(step_size) do
    %{buffer_size: 1, nearest: nil, idx: 0}
    |> run(step_size)
  end
 
  defp grow([_h | [x | _t]], _step_size, 2018), do: x
  defp grow(deque, step_size, count) do
    deque
    |> rotate(rem(step_size, length(deque)))
    |> List.insert_at(1, count)
    |> rotate(1)
    |> grow(step_size, count + 1)
  end

  defp run(%{:buffer_size => 50000001, nearest: x}, _step_size), do: x
  defp run(state, step_size) do
    new_pos = rem(step_size + state.idx, state.buffer_size)
    #IO.inspect(state)
    if new_pos == 0 do
      state
      |> Map.put(:nearest, state.buffer_size)
      |> Map.update!(:buffer_size, &(&1 + 1))
      |> Map.put(:idx, 1)
      |> run(step_size)
    else
      state
      |> Map.update!(:buffer_size, &(&1 + 1))
      |> Map.put(:idx, new_pos + 1)
      |> run(step_size)
    end
  end

  defp rotate(list, steps) do
    {l, r} = Enum.split(list, steps)
    r ++ l
  end
end
