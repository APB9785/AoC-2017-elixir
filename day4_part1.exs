defmodule Passphrases do
  def check_all do
    File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.count(&is_valid?/1)
  end

  def is_valid?(str_input) do
    appearances = str_input
    |> String.split(" ")
    |> Enum.frequencies
    |> Map.values
    |> Enum.max

    appearances < 2
  end
end
