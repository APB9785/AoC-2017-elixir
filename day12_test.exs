defmodule NodeGroupsTest do
  use ExUnit.Case
  doctest NodeGroups

  test "Example Part 1" do
    assert NodeGroups.root_size("example.txt") == 6
  end

  test "Puzzle Part 1" do
    assert NodeGroups.root_size("input.txt") == 378
  end

  test "Example Part 2" do
    assert NodeGroups.unique("example.txt") == 2
  end

  test "Puzzle Part 2" do
    assert NodeGroups.unique("input.txt") == 204
  end
end
