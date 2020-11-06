defmodule SpiralMemory do
  @dir_order %{"R" => "U", "U" => "L", "L" => "D", "D" => "R"}

  defstruct x: 0, y: 0,
            steps: 1,
            limit: None,
            total_edges: 0,
            edge_length: 1,
            edge_progress: 0,
            direction: "R",
            seen: %{{0, 0} => 1}

  def last_value(int_input) do
    %SpiralMemory{limit: int_input}
    |> travel
  end

  defp travel(state) do
    new_state = state
    |> take_step
    |> check_edge
    |> add_seen

    if new_state.seen[{new_state.x, new_state.y}] > new_state.limit do
      new_state.seen[{new_state.x, new_state.y}]
    else
      travel(new_state)
    end
  end
  
  defp take_step(state) do
    new_state = state
    |> Map.update!(:steps, &(&1 + 1))
    |> Map.update!(:edge_progress, &(&1 + 1))

    cond do
      new_state.direction == "R" ->
        Map.update!(new_state, :x, &(&1 + 1))
      new_state.direction == "U" ->
        Map.update!(new_state, :y, &(&1 + 1))
      new_state.direction == "L" ->
        Map.update!(new_state, :x, &(&1 - 1))
      new_state.direction == "D" ->
        Map.update!(new_state, :y, &(&1 - 1))
    end
  end

  defp check_edge(state) do
    if state.edge_progress == state.edge_length do
      state
      |> Map.put(:edge_progress, 0)
      |> Map.update!(:total_edges, &(&1 + 1))
      |> Map.update!(:direction, &(@dir_order[&1]))
      |> even_edges
    else
      state
    end
  end
 
  defp even_edges(state) do
    if rem(state.total_edges, 2) == 0 do
      Map.update!(state, :edge_length, &(&1 + 1))
    else
      state
    end
  end

  defp sum_neighbors(state) do
    Enum.sum([Map.get(state.seen, {state.x - 1, state.y}, 0),
              Map.get(state.seen, {state.x - 1, state.y - 1}, 0),
              Map.get(state.seen, {state.x, state.y - 1}, 0),
              Map.get(state.seen, {state.x + 1, state.y - 1}, 0),
              Map.get(state.seen, {state.x + 1, state.y}, 0),
              Map.get(state.seen, {state.x + 1, state.y + 1}, 0),
              Map.get(state.seen, {state.x, state.y + 1}, 0),
              Map.get(state.seen, {state.x - 1, state.y + 1}, 0)])
  end

  defp add_seen(state) do
    Map.update!(state,
                :seen, 
                &Map.put(&1, 
                         {state.x, state.y},
                         sum_neighbors(state))) 
  end
end

IO.puts SpiralMemory.last_value(265149)
