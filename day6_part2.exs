defmodule Part2 do
  def make_state do
    mem = File.read!("input.txt")
    |> String.trim
    |> String.split("\t")
    |> Enum.reduce(%{}, &Map.put(&2, map_size(&2), String.to_integer(&1)))
    %{banks: mem,
      cycles: 0,
      seen: [List.to_tuple(Map.values(mem))],
      loop: false}
  end

  def balance(state) do
    {idx, val} = Enum.max_by(state.banks, fn x -> elem(x, 1) end)
    next_state = state
    |> Map.update!(:cycles, &(&1 + 1))
    |> Map.update!(:banks,
                   &zero(&1, idx))
    |> Map.update!(:banks,
                   &distribute(&1, rem(idx+1, 16), val))

    IO.inspect Map.values(next_state.banks)

    cond do
      seen?(next_state.seen, next_state.banks) and next_state.loop ->
        to_string(next_state.cycles) <> " cycles in loop."
      seen?(next_state.seen, next_state.banks) ->
        IO.puts "\n-------- LOOP STARTS --------\n"
        next_state
        |> Map.put(:cycles, 0)
        |> Map.put(:loop, True)
        |> Map.put(:seen, [List.to_tuple(Map.values(next_state.banks))])
        |> balance
      True ->
        Map.update!(next_state,
                    :seen,
                    &add_seen(&1, next_state.banks))
        |> balance
    end
  end

  def zero(map, idx) do
    Map.put(map, idx, 0)
  end

  def seen?(list, current_bank) do
    Enum.member?(list,
                 List.to_tuple(Map.values(current_bank)))
  end

  defp add_seen(seen, mem_banks) do
    to_add = mem_banks
    |> Map.values
    |> List.to_tuple
   
    [to_add | seen]
  end

  defp distribute(map, _idx, 0), do: map

  defp distribute(map, idx, cache) do
    distribute(Map.update!(map, idx, &(&1 + 1)),
               rem(idx + 1, 16),
               cache - 1)
  end
end

IO.puts Part2.balance(Part2.make_state)
