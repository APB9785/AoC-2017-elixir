defmodule KnotHash do
  def init do
    lengths = File.read!("input.txt")
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    
    %{lengths: lengths, nums: Enum.to_list(0..255), skip: 0, pos: 0}
    |> run
  end

  ##########################################################################

  defp run(%{lengths: []} = state), do: product(Enum.slice(state.nums, 0..1))
  defp run(state) do
    state
    |> Map.update!(:nums, &tie(&1, state.pos, hd(state.lengths)))
    |> Map.update!(:pos, &rem(&1 + hd(state.lengths) + state.skip, 256))
    |> Map.update!(:skip, &(&1 + 1))
    |> Map.put(:lengths, tl(state.lengths))
    |> run
  end

  defp tie(nums_list, position, length) do
    nums_list
    |> rot_left(position)
    |> Enum.reverse_slice(0, length)
    |> rot_right(position)
  end

  defp rot_left(nums_list, position) do
    {l, r} = Enum.split(nums_list, position)
    r ++ l
  end

  defp rot_right(nums_list, position) do
    {l, r} = Enum.split(nums_list, 256 - position)
    r ++ l
  end

  defp product(list), do: Enum.reduce(list, 1, &(&1 * &2))
end
