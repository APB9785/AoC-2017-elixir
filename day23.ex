defmodule Script do
  @moduledoc """
  Documentation for `Script`.
  """

  @registers ["a", "b", "c", "d", "e", "f", "g", "h"]

  @doc """
  Hello world.

  ## Examples

      Script.part_one("input.txt")

  """
  def part_one(filename) do
    state = %{regs: Enum.reduce(@registers, %{}, &Map.put(&2, &1, 0)),
              todo: filename |> File.read! |> String.trim |> String.split("\n"),
              done: [],
              count: 0}

    state |> run
  end

  defp run(%{:todo => []} = state), do: state.count
  defp run(%{:todo => [h | _t]} = state) do
    [command, x, y] = String.split(h, " ")

    case command do
      "set" ->
        state
        |> Map.update!(:regs, &set(&1, x, y))
        |> move_forward(1)
        |> run
      "sub" ->
        state
        |> Map.update!(:regs, &sub(&1, x, y))
        |> move_forward(1)
        |> run
      "mul" ->
        state
        |> Map.update!(:regs, &mul(&1, x, y))
        |> Map.update!(:count, &(&1 + 1))
        |> move_forward(1)
        |> run
      "jnz" ->
        if check_val(x, state.regs) == 0 do
          state |> move_forward(1) |> run
        else
          state |> move_variable(y) |> run
        end
    end
  end

  defp set(regs, x, y), do: Map.put(regs, x, check_val(y, regs))

  defp sub(regs, x, y), do: Map.update!(regs, x, &(&1 - check_val(y, regs)))

  defp mul(regs, x, y), do: Map.update!(regs, x, &(&1 * check_val(y, regs)))

  defp move_variable(state, y) do
    case check_val(y, state.regs) do
      n when n > 0 -> state |> move_forward(n)
      n when n < 0 -> state |> move_backward(-n)
    end
  end

  defp move_forward(state, 0), do: state
  defp move_forward(%{:todo => [h | t]} = state, steps) do
    state
    |> Map.put(:todo, t)
    |> Map.update!(:done, &([h | &1]))
    |> move_forward(steps - 1)
  end

  defp move_backward(state, 0), do: state
  defp move_backward(%{:done => [h | t]} = state, steps) do
    state
    |> Map.put(:done, t)
    |> Map.update!(:todo, &([h | &1]))
    |> move_backward(steps - 1)
  end

  defp check_val(input, regs) do
    if input in @registers do
      regs[input]
    else
      String.to_integer(input)
    end
  end
end
