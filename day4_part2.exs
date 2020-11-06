defmodule Passphrases do
  def check_all do
    File.read!("input.txt")
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.count(&is_valid?/1)
  end

  def is_valid?(str_input) do
    str_input
    |> String.split(" ") 
    |> Enum.map(&alphabetize_string/1)
    |> Enum.frequencies
    |> Map.values
    |> Enum.max
    |> less_than_two?
  end

  def alphabetize_string(str_input) do
    str_input
    |> String.graphemes
    |> Enum.sort
    |> List.to_string
  end

  def less_than_two?(str), do: str < 2
end
