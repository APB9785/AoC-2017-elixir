defmodule HexGridTest do
  use ExUnit.Case
  doctest HexGrid

  test "Example 1" do
    assert HexGrid.end_distance("ne,ne,ne") == 3
  end

  test "Example 2" do
    assert HexGrid.end_distance("ne,ne,sw,sw") == 0
  end

  test "Example 3" do
    assert HexGrid.end_distance("ne,ne,s,s") == 2
  end

  test "Example 4" do
    assert HexGrid.end_distance("se,sw,se,sw,sw") == 3
  end

  test "Puzzle Part 1" do
    assert HexGrid.end_distance() == 643
  end

  test "Furthest Distance with String" do
    assert HexGrid.furthest_distance("ne,ne,sw,sw") == 2
  end

  test "Puzzle Part 2" do
    assert HexGrid.furthest_distance() == 1471
  end
end
