defmodule Tower do
  def run do
    full_list = File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)

    weights = full_list
    |> Enum.reduce(%{}, &map_weights/2)

    base = full_list
    |> Enum.filter(&Regex.match?(~r/->/, &1))
    |> Enum.reduce(%{}, &map_supports/2)
    |> scan_for_base

    towers = full_list
    |> Enum.filter(&Regex.match?(~r/->/, &1))
    |> Enum.reduce(%{}, &map_towers/2)

    balance(%{weights: weights, towers: towers},
            base)
  end


  ###################################################################


  defp balance(state, base, last_offset \\ nil) do
    name_list = Map.get(state.towers, base)
    weight_list = Enum.map(name_list, &full_weight(state, &1))

    if balanced?(weight_list) do
      Map.get(state.weights, base) - last_offset
    else
      balance(state,
              find_bad_tower(name_list, weight_list),
              find_offset(weight_list)) 
    end
  end


  defp balanced?(weight_list) do
    length(Enum.uniq(weight_list)) == 1
  end


  defp find_bad_tower(name_list, weight_list) do
    if length(name_list) > 2 do
      bad_weight = weight_list
      |> Enum.frequencies
      |> Map.to_list
      |> Enum.filter(&freq_is_one?/1)
      |> hd
      |> elem(0)

      List.zip([name_list, weight_list])
      |> Enum.filter(&weight_is_bad?(&1, bad_weight))
      |> hd
      |> elem(0)
    else
      nil # Problem does not include this case
    end
  end


  defp weight_is_bad?(tup, bad_weight) do
    elem(tup, 1) == bad_weight
  end


  defp find_offset(weight_list) do
    subtract(Enum.min_by(weight_list,
                         &quantity(&1, weight_list)),
             Enum.max_by(weight_list,
                         &quantity(&1, weight_list)))
  end


  defp freq_is_one?(tup), do: elem(tup, 1) == 1


  defp full_weight(state, to_check) do
    full_weight(state, [to_check], 0)
  end

  defp full_weight(_state, [], count), do: count

  defp full_weight(state, to_check, count) do
    [now | later] = to_check
    
    full_weight(state,
                later ++ Map.get(state.towers, now, []),
                count + Map.get(state.weights, now))
  end


  defp map_weights(line, acc) do
    Map.put(acc,
            parse_name(line),
            parse_weight(line))
  end


  defp map_supports(line, acc) do
    [base, towers] = Regex.run(~r/([a-z]+) \([0-9]+\) -> ([a-z ,]+)/,
                               line)
    |> tl # Removes the full match

    String.split(towers, ", ")
    |> Enum.reduce(%{}, &Map.put(&2, &1, base))
    |> Map.merge(acc)
  end


  defp map_towers(line, acc) do
    [base, towers] = Regex.run(~r/([a-z]+) \([0-9]+\) -> ([a-z ,]+)/,
                               line)
    |> tl

    Map.put(acc,
            base,
            String.split(towers, ", "))
  end


  defp parse_name(line) do
    Regex.run(~r/[a-z]+/, line)
    |> hd
  end


  defp parse_weight(line) do
    Regex.run(~r/[0-9]+/, line)
    |> hd
    |> String.to_integer
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

  defp quantity(weight, weight_list) do
    Enum.count(weight_list,
               fn x -> x == weight end)
  end

  defp subtract(x, y), do: x - y
end
