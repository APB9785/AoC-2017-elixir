defmodule Duet do
  @moduledoc """
  Runs Duet assembly code.
  """

  @alphabet ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
             "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
             "u", "v", "w", "x", "y", "z"]

  @doc """
  Hello world.

  ## Examples

      Duet.part_1("input.txt")

  """
  def part_1(filename) do
    File.read!(filename)
    |> String.trim
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> make_state
    |> run
  end

  defp make_state(input_list) do
    registers = input_list
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.uniq
    |> Enum.reduce(%{}, &Map.put(&2, &1, 0))

    %{done: [],
      todo: input_list,
      reg: registers,
      term: false,
      freq: nil}
  end

  defp run(%{:term => true} = state), do: state

  defp run(%{:todo => [["set", x, y] | _next]} = state) do
    state
    |> Map.update!(:reg, &Map.put(&1, x, check(&1, y)))
    |> move_forward(1)
    |> run
  end

  defp run(%{:todo => [["add", x, y] | _next]} = state) do
    state
    |> Map.update!(:reg, &add(&1, x, check(&1, y)))
    |> move_forward(1)
    |> run
  end

  defp run(%{:todo => [["mul", x, y] | _next]} = state) do
    state
    |> Map.update!(:reg, &mul(&1, x, check(&1, y)))
    |> move_forward(1)
    |> run
  end

  defp run(%{:todo => [["mod", x, y] | _next]} = state) do
    state
    |> Map.update!(:reg, &mod(&1, x, check(&1, y)))
    |> move_forward(1)
    |> run
  end

  defp run(%{:todo => [["snd", x] | _next]} = state) do
    state
    |> Map.put(:freq, check(state.reg, x))
    |> move_forward(1)
    |> run
  end

  defp run(%{:todo => [["rcv", x] | _next]} = state) do
    if check(state.reg, x) != 0 do
      state.freq
    else
      state
      |> move_forward(1)
      |> run
    end
  end

  defp run(%{:todo => [["jgz", x, y] | _next]} = state) do
    if check(state.reg, x) > 0 do
      jump(state,
           check(state.reg, y))
      |> run
    else
      state
      |> move_forward(1)
      |> run
    end
  end

  defp add(registers, x, y), do: Map.update!(registers, x, &(&1 + y))

  defp mul(registers, x, y), do: Map.update!(registers, x, &(&1 * y))

  defp mod(registers, x, y), do: Map.update!(registers, x, &rem(&1, y))

  defp jump(state, offset) do
    cond do
      offset == 0 ->
        "Bad Jump"
      offset > 0 ->
        move_forward(state, offset)
      offset < 0 ->
        move_backward(state, 0 - offset)
    end
  end

  defp move_forward(state, 0), do: state

  defp move_forward(%{:todo => []} = state, _count) do
    Map.put(state, :term, true)
  end

  defp move_forward(%{:todo => [curr | next]} = state, count) do
    state
    |> Map.put(:done, [curr | state.done])
    |> Map.put(:todo, next)
    |> move_forward(count - 1)
  end

  defp move_backward(state, 0), do: state

  defp move_backward(%{:done => []} = state, _count) do
    Map.put(state, :term, true)
  end

  defp move_backward(%{:done => [last | stack]} = state, count) do
    state
    |> Map.put(:todo, [last | state.todo])
    |> Map.put(:done, stack)
    |> move_backward(count - 1)
  end

  ########################  part 2  ################################

  def part_2(filename) do
    input_list = File.read!(filename)
    |> String.trim
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))

    state_0 = make_full_state(0, input_list)
    state_1 = make_full_state(1, input_list)

    handle(state_0, state_1)
  end

  defp make_full_state(p_value, todo_list) do
    %{reg: %{"p" => p_value},
      done: [],
      todo: todo_list,
      mail: [],
      sent: 0,
      id: p_value}
  end

  defp handle(%{:todo => [["rcv", _] | _], :mail => []} = state_a,
              %{:todo => [["rcv", _] | _], :mail => []} = state_b) do
    finish(state_a, state_b)
  end

  defp handle(state_a, state_b) do
    case state_a.todo do
      [["rcv", x] | _] ->
        if state_a.mail == [] do
          handle(state_b, state_a)
        else
          state_a
          |> Map.update!(:reg, &Map.put(&1, x, hd(state_a.mail)))
          |> Map.update!(:mail, &tl/1)
          |> move_forward(1)
          |> handle(state_b)
        end

      [["snd", x] | _] ->
        state_a
        |> move_forward(1)
        |> Map.update!(:sent, &(&1 + 1))
        |> handle(Map.update!(state_b, :mail, fn box ->
                    box ++ [check(state_a.reg, x)] end))

      [["set", x, y] | _] ->
        state_a
        |> Map.update!(:reg, &Map.put(&1, x, check(&1, y)))
        |> move_forward(1)
        |> handle(state_b)

      [["add", x, y] | _] ->
        state_a
        |> Map.update!(:reg, &add(&1, x, check(&1, y)))
        |> move_forward(1)
        |> handle(state_b)

      [["mul", x, y] | _] ->
        state_a
        |> Map.update!(:reg, &mul(&1, x, check(&1, y)))
        |> move_forward(1)
        |> handle(state_b)

      [["mod", x, y] | _] ->
        state_a
        |> Map.update!(:reg, &mod(&1, x, check(&1, y)))
        |> move_forward(1)
        |> handle(state_b)
        
      [["jgz", x, y] | _] ->
        if check(state_a.reg, x) > 0 do
          jump(state_a, check(state_a.reg, y)) |> handle(state_b)
        else
          state_a |> move_forward(1) |> handle(state_b)
        end
    end
  end

  defp check(registers, key) do
    if key in @alphabet do
      Map.get(registers, key, 0)
    else
      String.to_integer(key)
    end
  end

  defp finish(state_a, state_b) do
    if state_a.id == 1 do
      state_a.sent
    else
      state_b.sent
    end
  end
end
