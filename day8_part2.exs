defmodule Registers do
  def read do
    instructions = File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    
    zero_state = %{best: 0,
                   reg: Enum.reduce(instructions, %{}, &init/2)}

    end_state = instructions
    |> Enum.reduce(zero_state, &run/2)

    end_state.best
  end


  #############################################################


  defp init(line, acc) do
    m = Regex.named_captures(~r/(?<n_1>[a-z]+)
                                \s[a-z]+\s-?[0-9]+\sif\s
                                (?<n_2>[a-z]+)
                                \s[<>=!]+\s-?[0-9]+/x,
                             line)
    
    acc
    |> Map.put_new(m["n_1"], 0)
    |> Map.put_new(m["n_2"], 0)
  end


  defp run(line, state) do
    m = Regex.named_captures(~r/(?<key>[a-z]+)\s
                                (?<op>[a-z]+)\s
                                (?<amt>-?[0-9]+)\sif\s
                                (?<c_1>[a-z]+)\s
                                (?<comp>[<>=!]+)\s
                                (?<c_2>-?[0-9]+)/x,
                             line)

    
    if comparison?(state.reg, m["c_1"], m["comp"], m["c_2"]) do
      new_state = Map.update!(state,
                              :reg,
                              &update_reg(&1, m["key"], m["op"], m["amt"]))

      Map.update!(new_state,
                  :best,
                  &update_best(&1, new_state.reg))
    else
      state
    end
  end

  defp update_best(old_best, reg_map) do
    current_best = reg_map
    |> Map.values
    |> Enum.max

    if current_best > old_best do
      current_best
    else
      old_best
    end
  end

  defp update_reg(reg_map, key, op, amt) do
    Map.update!(reg_map, key, &change(&1, op, amt))
  end

  defp change(value, operator, offset) do
    cond do
      operator == "inc" ->
        value + String.to_integer(offset)
      operator == "dec" ->
        value - String.to_integer(offset)
    end
  end

  defp comparison?(state, c_1, "<=", c_2), do: state[c_1] <= String.to_integer(c_2)
  defp comparison?(state, c_1, "<", c_2), do: state[c_1] < String.to_integer(c_2)
  defp comparison?(state, c_1, "==", c_2), do: state[c_1] == String.to_integer(c_2)
  defp comparison?(state, c_1, "!=", c_2), do: state[c_1] != String.to_integer(c_2)
  defp comparison?(state, c_1, ">=", c_2), do: state[c_1] >= String.to_integer(c_2)
  defp comparison?(state, c_1, ">", c_2), do: state[c_1] > String.to_integer(c_2)
end

IO.puts Registers.read
