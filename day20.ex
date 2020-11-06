defmodule Swarm do
  @moduledoc """
  Simulates particles with constant acceleration moving through space.
  """

  @doc """
  Finds the id of the particle which remains closest to the origin over time.

  ## Examples

      Swarm.part_one("input.txt")

  """
  def part_one(filename) do
    Regex.scan(~r/p=<([\S]+)>, v=<([\S]+)>, a=<([\S]+)>/,
               File.read!(filename))
    |> make_state
    |> part_one_loop
  end

  @doc """
  Finds the number of particles remaining after all colliding particles
  are removed from the system.

  ## Examples

      Swarm.part_two("input.txt")

  """
  def part_two(filename) do
    Regex.scan(~r/p=<([\S]+)>, v=<([\S]+)>, a=<([\S]+)>/,
               File.read!(filename))
    |> make_state
    |> part_two_loop
  end

  def run(state, id \\ 0)
  def run(state, 1000), do: state
  def run(state, id) do
    case Map.get(state, id) do
      nil -> run(state, id + 1)
      particle ->
        new_particle = particle
        |> update_velocity
        |> update_position

        Map.put(state, id, new_particle)
        |> run(id + 1)
    end
  end

  def furthest_from_origin(state, id \\ 0, best \\ {-1, :infinity})
  def furthest_from_origin(_, 1000, {best_id, _}), do: best_id
  def furthest_from_origin(state, id, {best_id, best_dist}) do
    %{:pos => {a, b, c}} = state[id]
    dist = abs(a)+abs(b)+abs(c)

    if dist < best_dist do
      furthest_from_origin(state, id + 1, {id, dist})
    else
      furthest_from_origin(state, id + 1, {best_id, best_dist})
    end
  end

  def check_for_collisions(state, seen \\ [], id \\ 0)
  def check_for_collisions(state, seen, 1000), do: {state, seen}
  def check_for_collisions(state, seen, id) do
    case Map.get(state, id) do
      nil -> check_for_collisions(state, seen, id + 1)
      particle ->
        check_for_collisions(state, [particle.pos | seen], id + 1)
    end
  end

  defp remove_collisions({state, seen}) do
    collisions = Enum.frequencies(seen)
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> Keyword.keys

    Enum.reject(state,
                fn {_id, particle} ->
                  particle.pos in collisions end)
    |> Map.new
  end

  defp part_one_loop(state, res \\ [])
  defp part_one_loop(_state, res) when length(res) > 200, do: hd(res)
  defp part_one_loop(state, res) do
    new_res = furthest_from_origin(state)
    new_state = run(state)

    if new_res in res or res == [] do
      part_one_loop(new_state, [new_res | res])
    else
      part_one_loop(new_state, [new_res])
    end
  end

  defp part_two_loop(state, res \\ [])
  defp part_two_loop(_state, res) when length(res) > 50, do: hd(res)
  defp part_two_loop(state, res) do
    new_state = state
    |> check_for_collisions
    |> remove_collisions
    new_res = map_size(new_state)

    if new_res in res or res == [] do
      new_state
      |> run
      |> part_two_loop([new_res | res])
    else
      new_state
      |> run
      |> part_two_loop([new_res])
    end
  end

  # Creates the initial state
  defp make_state(list, state \\ %{}, count \\ 0)
  defp make_state([], state, _count), do: state
  defp make_state([[_, pos, vel, acc] | t], state, count) do
    new_state = Map.put(state,
                        count,
                        %{pos: make_tuple(pos),
                          vel: make_tuple(vel),
                          acc: make_tuple(acc)})

    make_state(t, new_state, count + 1)
  end

  defp update_velocity(%{:vel => {v_x, v_y, v_z},
                       :acc => {a_x, a_y, a_z}} = particle) do
    new_vel = {v_x + a_x, v_y + a_y, v_z + a_z}
    Map.put(particle, :vel, new_vel)
  end

  defp update_position(%{:pos => {p_x, p_y, p_z},
                       :vel => {v_x, v_y, v_z}} = particle) do
    new_pos = {p_x + v_x, p_y + v_y, p_z + v_z}
    Map.put(particle, :pos, new_pos)
  end

  # Splits a string into a tuple of integers
  defp make_tuple(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end
