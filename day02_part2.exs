defmodule Part2 do
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

  defp find_even_divide(list_input) do
    find_even_divide(hd(list_input), tl(list_input), list_input)
  end

  defp find_even_divide(current, next, whole) do
    nums = Enum.filter(whole, fn x -> rem(x, current) == 0 end)
    if length(nums) < 2 do 
      find_even_divide(hd(next), tl(next), whole)
    else
      div(Enum.max(nums), Enum.min(nums))
    end
  end

  def handle_lines do
    parse_input()
    |> Enum.map(&find_even_divide/1)
    |> Enum.sum
  end
end

IO.puts Part2.handle_lines
