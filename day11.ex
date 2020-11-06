defmodule HexGrid do
  @moduledoc """
  Tracks steps taken in a "flat" style hex grid.
  """

  @doc """
  Calculates the distance from origin after all steps have been taken.
  May pass a string as input, or if no string is passed, input.txt will
  be read for input instead.

  ## Examples

      HexGrid.end_distance("ne,ne,ne")
      
      HexGrid.end_distance() 

  """
  def end_distance do
    {x, y, z} = File.read!("input.txt")
    |> String.trim
    |> String.split(",")
    |> Enum.reduce({0, 0, 0}, &walk/2)

    Enum.max([x, y, z])
  end
  
  def end_distance(string) do
    {x, y, z} = string
    |> String.split(",")
    |> Enum.reduce({0, 0, 0}, &walk/2)
    
    Enum.max([x, y, z])
  end

  @doc """
  Calculates the furthest distance from origin reached along a path.
  May pass a string as input, or if no string is passed, input.txt will
  be read for input instead.

  ## Examples

      HexGrid.furthest_distance("ne,ne,ne")

      HexGrid.furthest_distance()

  """
  def furthest_distance do
    File.read!("input.txt")
    |> String.trim
    |> String.split(",")
    |> track({0, 0, 0}, 0)
  end

  def furthest_distance(string) do
    string
    |> String.split(",")
    |> track({0, 0, 0}, 0)
  end

  # This function takes a single step
  defp walk("ne", {x, y, z}), do: {x+1, y, z-1}
  defp walk("n", {x, y, z}), do: {x, y+1, z-1}
  defp walk("nw", {x, y, z}), do: {x-1, y+1, z}
  defp walk("sw", {x, y, z}), do: {x-1, y, z+1}
  defp walk("s", {x, y, z}), do: {x, y-1, z+1}
  defp walk("se", {x, y, z}), do: {x+1, y-1, z}
  
  # Reduces the list while keeping count of furthest distance
  defp track([], _coords, furthest), do: furthest
  defp track([h | t], coords, furthest) do
    {x, y, z} = walk(h, coords)

    track(t, {x, y, z}, Enum.max([x, y, z, furthest]))
  end
end
