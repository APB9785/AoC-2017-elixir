defmodule NodeGroups do
  @moduledoc """
  Counts clusters of connected nodes.
  """

  @doc """
  Counts how many nodes are connected to the first node (including itself).
  Pass the name of the input file as the first and only argument.

  ## Examples

      NodeGroups.root_size("input.txt")

  """
  def root_size(filename) do
    conns_map = File.read!(filename)
    |> String.split("\n", trim: true)
    |> make_map
       
    scan_group(conns_map,
               Enum.min(Map.keys(conns_map)))
    |> length
  end

  @doc """
  Counts the number of unique (unconnected) groups among all nodes.
  Pass the name of the input file as the first and only argument.

  ## Examples

      NodeGroups.unique("input.txt")

  """
  def unique(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> make_map
    |> scan_all
  end

  # Maps node => [connections]
  defp make_map(list, acc \\ %{})
  defp make_map([], acc), do: acc
  defp make_map([h | t], acc) do
    [base, conns] = String.split(h, " <-> ")
    conns_list = String.split(conns, ", ")
    new_map = Map.put(acc,
                      String.to_integer(base),
                      Enum.map(conns_list, 
                               &String.to_integer/1))

    make_map(t, new_map)
  end

  # Iteratively walks through all connections from start_node.
  defp scan_group(conns_map, start_node) do
    scan_group(conns_map, conns_map[start_node], [start_node])
  end

  defp scan_group(_conns_map, [], seen), do: seen

  defp scan_group(conns_map, [h | t], seen) do
    if h not in seen do
      scan_group(conns_map, conns_map[h] ++ t, [h | seen])
    else
      scan_group(conns_map, t, seen)
    end
  end

  # Runs scan_group on each node until all groups have been found.
  # Skips nodes that have already been seen.
  defp scan_all(conns_map) do
    {lo, hi} = Enum.min_max(Map.keys(conns_map))
    scan_all(conns_map,
             Enum.to_list(lo..hi),
             [], 0)
  end

  defp scan_all(_conns_map, [], _seen, group_count), do: group_count

  defp scan_all(conns_map, [h | t], seen, group_count) do
    if h not in seen do
      new_seen = scan_group(conns_map, [h], seen)
      scan_all(conns_map, t, new_seen, group_count + 1)
    else
      scan_all(conns_map, t, seen, group_count)
    end
  end
end
