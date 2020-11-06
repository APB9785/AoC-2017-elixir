defmodule Part1 do
  @dir_order %{"R" => "U", "U" => "L", "L" => "D", "D" => "R"}

  def distance(int_input) do
    state = %{x: 0, y: 0,
              steps: 1,
              limit: int_input,
              total_edges: 0,
              edge_length: 1,
              edge_progress: 0,
              direction: "R"}
    {x, y} = travel(state)
    abs(x) + abs(y)
  end

  def travel(state) do
    new_state = state
    |> Part1.take_step
    |> Part1.check_edge

    if new_state.steps == new_state.limit do
      {new_state.x, new_state.y}
    else
      Part1.travel(new_state)
    end
  end
  
  def take_step(state) do
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

  def check_edge(state) do
    if state.edge_progress == state.edge_length do
      state
      |> Map.put(:edge_progress, 0)
      |> Map.update!(:total_edges, &(&1 + 1))
      |> Map.update!(:direction, &(@dir_order[&1]))
      |> Part1.even_edges
    else
      state
    end
  end
 
  def even_edges(state) do
    if rem(state.total_edges, 2) == 0 do
      Map.update!(state, :edge_length, &(&1 + 1))
    else
      state
    end
  end
end

IO.puts Part1.distance(265149)
