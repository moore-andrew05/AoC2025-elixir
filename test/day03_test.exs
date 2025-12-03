defmodule Aoc2025.Day03Test do
  use ExUnit.Case
  alias Aoc2025.Day03
  @part1_input "987654321111111
811111111111119
234234234234278
818181911112111"

  describe "part1/1" do
    test "two sum max" do
      assert Day03.part1(@part1_input) == 357
    end
  end

  describe "part2/1" do
    test "part2 description" do
      assert Day03.part2(@part1_input) == 3121910778619
    end
  end
end
