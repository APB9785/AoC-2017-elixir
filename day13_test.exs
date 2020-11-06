defmodule FirewallTest do
  use ExUnit.Case
  doctest Firewall

  test "part 1 example" do
    assert Firewall.severity("example.txt") == 24
  end

  test "part 1 full input" do
    assert Firewall.severity("input.txt") == 1632
  end
  
  test "part 2 example" do
    assert Firewall.clear_pass("example.txt") == 10
  end

  test "part 2 full input" do
    assert Firewall.clear_pass("input.txt") == 3834136
  end
end
