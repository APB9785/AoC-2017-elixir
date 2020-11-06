defmodule Part2 do
  defp parse_input do
    File.read!("input.txt")
    |> String.graphemes
    |> List.delete_at(-1)
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  defp count(m) do
    parse_input()
    |> count(m, div(map_size(m), 4), 0)
  end 

  defp count([], _m, _i, c), do: c

  defp count(l, m, i, c) do
    if m[i] == hd(l) do
      count(tl(l), m, i+1, c+hd(l))
    else
      count(tl(l), m, i+1, c)
    end
  end

  def count_em() do
    l = parse_input()

    m = Enum.reduce(l, %{}, fn x, acc -> Map.put(acc, map_size(acc), x) end)
    
    Enum.reduce(l, m, fn x, acc -> Map.put(acc, map_size(acc), x) end)
    |> count
  end
end

IO.puts(Part2.count_em)
