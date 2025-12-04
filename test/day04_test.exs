defmodule Aoc2025.Day04Test do
  @puzzle_input "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
"
  use ExUnit.Case
  alias Aoc2025.Day04

  describe "part1/1" do
    test "single iteration" do
      assert Day04.part1(@puzzle_input) == 13
    end
  end

  describe "part2/1" do
    test "iterate until complete" do
      assert Day04.part2(@puzzle_input) == 43
    end
  end
end
