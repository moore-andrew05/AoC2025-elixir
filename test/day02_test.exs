defmodule Aoc2025.Day02Test do
  use ExUnit.Case
  alias Aoc2025.Day02
  @part1_test_input "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

  describe "part1/1" do
    test "part 1" do
      assert Day02.part1(@part1_test_input) == 1227775554
    end
  end

  describe "part2/1" do
    test "part2 description" do
      assert Day02.part2(@part1_test_input) == 4174379265
    end
  end
end
