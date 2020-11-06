defmodule Part1 do
  defp parse_input do
    File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.map(&line_to_nums/1)
  end

  defp line_to_nums(str_input) do
    str_input
    |> String.split("\t")
    |> Enum.map(&String.to_integer/1)
  end

  def handle_lines do
    parse_input()
    |> Enum.map(fn x -> Enum.max(x) - Enum.min(x) end)
    |> Enum.sum
  end
end
