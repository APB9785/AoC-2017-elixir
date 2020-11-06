defmodule Registers do
  def read do
    instructions = File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    
    zero_state = instructions
    |> Enum.reduce(%{}, &init/2)

    end_state = instructions
    |> Enum.reduce(zero_state, &run/2)

    Enum.max(Map.values(end_state))
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
    
    if comparison?(state, m["c_1"], m["comp"], m["c_2"]) do
      Map.update!(state,
                  m["key"],
                  &change(&1, m["op"], m["amt"]))
    else
      state
    end
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
