defmodule Aoc2025.Day09Test do
  use ExUnit.Case
  alias Aoc2025.Day09
  @puzzle_input "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
"

  describe "part1/1" do
    test "part1 description" do
      assert Day09.part1(@puzzle_input) == 50
    end
  end

  describe "part2/1" do
    test "part2 description" do
      assert Day09.part2(@puzzle_input) == 24
    end
  end
end
