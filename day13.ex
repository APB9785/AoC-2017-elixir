defmodule Firewall do
  @moduledoc """
  Test packet runs through a firewall of security scanners.
  """

  @doc """
  Find the severity of a run through the firewall.

  ## Examples

      Firewall.severity("input.txt")

  """
  def severity(filename) do
    map = File.read!(filename)
    |> make_map
    
    run(map, Map.keys(map), 0)
  end

  @doc """
  Find the minimum delay required (in picoseconds) to pass through
  the firewall without ever getting caught by a scanner.

  ## Examples

      Firewall.clear_pass("input.txt")

  """
  def clear_pass(filename) do
    map = File.read!(filename)
    |> make_map

    run_loop(map, Map.keys(map), 0)
  end

  # Helper for severity
  defp run(_map, [], sev), do: sev
  defp run(map, [h | t], sev) do
    if rem(h, 2 * map[h] - 2) == 0 do
      run(map, t, map[h] * h + sev)
    else
      run(map, t, sev)
    end
  end

  # Helper for clear_pass
  defp run_loop(_map, [], delay), do: delay
  defp run_loop(map, [h | t], delay) do
    if rem(h + delay, 2 * map[h] - 2) == 0 do
      run_loop(map, Map.keys(map), delay + 1)
    else
      run_loop(map, t, delay)
    end
  end

  defp make_map(file_string) do
    file_string
    |> String.trim
    |> String.split("\n")
    |> Enum.reduce(%{}, &insert_into_map/2)
  end

  defp insert_into_map(line, acc) do
    [depth, range] = String.split(line, ": ")

    Map.put(acc,
            String.to_integer(depth),
            String.to_integer(range))
  end
end
