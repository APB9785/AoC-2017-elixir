defmodule Turing do
  @moduledoc """
  Documentation for `Turing`.
  """

  @doc """
  Hello world.

  ## Examples

      Turing.hello()
      :world

  """
  def run(filename) do
    File.read!(filename)
    |> make_struct
    |> loop
  end

  def make_struct(raw_str) do
    [h | [h2 | t]] = String.split(raw_str, "\n", trim: true)
    [_, begin_state] = Regex.run(~r/Begin in state ([A-Z])./, h)
    [run_length] = Regex.run(~r/[0-9]+/, h2) |> Enum.map(&String.to_integer/1)

    %{rules: parse_rules(t)}
    |> Map.put(:state, begin_state)
    |> Map.put(:run_length, run_length)
    |> Map.put(:index, 0)
    |> Map.put(:registers, %{})
  end

  def parse_rules(rules_list, acc \\ %{})
  def parse_rules([], acc), do: acc
  def parse_rules(rules_list, acc) do
    {[h1, _, h3, h4, h5, _, h7, h8, h9], t} = Enum.split(rules_list, 9)
    [_, current_state] = Regex.run(~r/In state ([A-Z]):/, h1)
    [zero_write] = Regex.run(~r/[0-9]+/, h3)
    [_, zero_dir] = Regex.run(~r/Move one slot to the ([a-z]+)./, h4)
    [_, zero_next] = Regex.run(~r/Continue with state ([A-Z])./, h5)
    [one_write] = Regex.run(~r/[0-9]+/, h7)
    [_, one_dir] = Regex.run(~r/Move one slot to the ([a-z]+)./, h8)
    [_, one_next] = Regex.run(~r/Continue with state ([A-Z])./, h9)

    rule = {{zero_write, zero_dir, zero_next}, {one_write, one_dir, one_next}}

    parse_rules(t, Map.put(acc, current_state, rule))
  end

  def loop(%{:run_length => 0} = struct), do: count(struct.registers)
  def loop(struct) do
    current_value = Map.get(struct.registers, struct.index, "0")
    {do_if_0, do_if_1} = Map.get(struct.rules, struct.state)
    if current_value == "0" do
      {write_val, direction, next_state} = do_if_0

      struct
      |> Map.update!(:registers, &Map.put(&1, struct.index, write_val))
      |> Map.update!(:index, &move_idx(&1, direction))
      |> Map.put(:state, next_state)
      |> Map.update!(:run_length, &(&1 - 1))
      |> loop
    else
      {write_val, direction, next_state} = do_if_1

      struct
      |> Map.update!(:registers, &Map.put(&1, struct.index, write_val))
      |> Map.update!(:index, &move_idx(&1, direction))
      |> Map.put(:state, next_state)
      |> Map.update!(:run_length, &(&1 - 1))
      |> loop
    end
  end

  defp count(regs), do: regs |> Map.values |> Enum.count(&(&1 == "1"))

  defp move_idx(current_idx, "left"), do: current_idx - 1
  defp move_idx(current_idx, "right"), do: current_idx + 1
end

# %{"A" => {{1, "right", "B"}, {0, "left", "B"}},
#   "B" => {{1, "left", "A"}, {1, "right", "A"}}
#  }
