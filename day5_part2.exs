defmodule JumpList do
  def count do
    File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.reduce(%{}, &map_by_index/2)
    |> start_jumping
  end

  defp map_by_index(item, map) do
    map
    |> Map.put(map_size(map),
               String.to_integer(item))
  end

  def start_jumping(map, position \\ 0, jumps \\ 0) do
    offset = map[position]
    cond do
      offset == nil ->
        jumps
      offset >= 3 ->
        start_jumping(Map.update!(map, position, &(&1 - 1)),
                      position + offset,
                      jumps + 1)
      offset < 3 ->
        start_jumping(Map.update!(map, position, &(&1 + 1)),
                      position + offset,
                      jumps + 1)
    end
  end
end
