defmodule KnotHash do
  use Bitwise

  def init do
    lengths = File.read!("input.txt")
    |> String.trim
    |> String.to_charlist
    |> Kernel.++([17, 31, 73, 47, 23])

    end_state = %{lengths: lengths,
                  nums: Enum.to_list(0..255),
                  skip: 0, pos: 0}
    |> full_loop

    end_state.nums
    |> Enum.chunk_every(16)
    |> dense_hash
    |> Enum.map(&to_hex/1)
    |> List.to_string
  end

  ##########################################################################

  defp full_loop(state, to_do \\ 64)
  defp full_loop(state, 0), do: state
  defp full_loop(state, to_do) do
    state
    |> run
    |> Map.put(:lengths, state.lengths)
    |> full_loop(to_do - 1)
  end

  defp run(%{lengths: []} = state), do: state
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

  defp dense_hash(sparse_chunked) do
    sparse_chunked
    |> Enum.reduce([], &xor_combine/2)
    |> Enum.reverse
  end

  defp xor_combine(chunk, acc) do
    [Enum.reduce(chunk, 0, &bxor/2) | acc]
  end

  defp rot_left(nums_list, position) do
    {l, r} = Enum.split(nums_list, position)
    r ++ l
  end

  defp rot_right(nums_list, position) do
    {l, r} = Enum.split(nums_list, 256 - position)
    r ++ l
  end

  defp to_hex(int) do
    Integer.to_string(int, 16)
    |> String.downcase
    |> String.pad_leading(2, "0")
  end
end
