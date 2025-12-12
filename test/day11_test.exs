defmodule Aoc2025.Day11Test do
  use ExUnit.Case
  alias Aoc2025.Day11
  @puzzle_input "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
"
  @puzzle_input2 "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
"

  describe "part1/1" do
    test "part1 description" do
      assert Day11.part1(@puzzle_input) == 5
    end
  end

  describe "part2/1" do
    test "part2 description" do
      assert Day11.part2(@puzzle_input2) == 2
    end
  end
end
