alias Aoc2025

day = List.first(System.argv())

day_module = Module.safe_concat(Aoc2025, day)

Benchee.run(%{
  "#{day}.part1" => fn -> day_module.part1() end,
  "#{day}.part2" => fn -> day_module.part2() end,
},
warmup: 4,
parallel: 1)
