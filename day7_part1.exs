defmodule Tower do
  def bottom_name do
    File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.filter(&Regex.match?(~r/->/, &1))
    |> Enum.reduce(%{}, &map_supports/2)
    |> scan_for_base
  end

  defp map_supports(line, acc) do
    [base, towers] = Regex.run(~r/([a-z]+) \([0-9]+\) -> ([a-z ,]+)/,
                               line)
    |> tl # Removes the full match

    String.split(towers, ", ")
    |> Enum.reduce(%{}, &Map.put(&2, &1, base))
    |> Map.merge(acc)
  end

  defp scan_for_base(map) do
    map
    |> Map.values
    |> Enum.random
    |> scan_for_base(map)
  end

  defp scan_for_base(name, map) do
    if name in Map.keys(map) do
      scan_for_base(map[name], map)
    else
      name
    end
  end
end
