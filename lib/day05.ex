defmodule MyRange do
  @enforce_keys [:low, :high]
  defstruct [
    :low,
    :high
  ]

  def in?(range, num) do
    cond do
      num <= range.high and num >= range.low -> true
      true -> false
    end
  end

  def size(range) do
    range.high - range.low + 1
  end
end

defimpl String.Chars, for: MyRange do
  def to_string(my_range) do
    "#{my_range.low}-#{my_range.high}"
  end
end

defmodule Aoc2025.Day05 do
  defp input do
    String.trim(File.read!("priv/inputs/day05.txt"))
  end

  def parse_range_from_str(range_str) do
    [low, high] =
      range_str
      |> String.split("-")
      |> Enum.map(&String.to_integer(&1))

    %MyRange{low: low, high: high}
  end

  def parse_input(input) do
    [db, ingredients] =
      input
      |> String.split("\n\n", trim: true)

    ingredients =
      ingredients
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer(&1))

    ranges =
      db
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_range_from_str(&1))

    {ranges, ingredients}
  end

  def binary_search?(ranges, val, l, r) when r - l <= 0 do
    MyRange.in?(elem(ranges, l), val)
  end

  def binary_search?(ranges, val, l, r) do
    mid = l + div(r - l, 2)
    mid_range = elem(ranges, mid)

    cond do
      MyRange.in?(mid_range, val) ->
        true

      val > mid_range.high ->
        binary_search?(ranges, val, mid + 1, r)

      val < mid_range.low ->
        binary_search?(ranges, val, l, mid)
    end
  end

  def consolidated_ranges(ranges) do
    chunk_fun = fn element, {chunk, prev_high} ->
      if element.low <= prev_high do
        {:cont, {[element | chunk], element.high}}
      else
        {:cont, chunk, {[element], element.high}}
      end
    end

    after_fun = fn
      {[], _} -> {:cont, []}
      {chunk, _} -> {:cont, chunk, {[], :infinity}}
    end

    chunked_ranges =
      ranges
      |> Enum.sort_by(fn x -> x.low end)
      |> Enum.sort_by(fn x -> x.high end)
      |> Enum.chunk_while({[], :ininity}, chunk_fun, after_fun)

    consolidated_ranges =
      chunked_ranges
      |> Enum.map(fn range ->
        low = Enum.min_by(range, fn x -> x.low end).low
        high = Enum.max_by(range, fn x -> x.high end).high
        %MyRange{low: low, high: high}
      end)

    consolidated_ranges
  end

  def part1(), do: part1(input())

  def part1(input) do
    {ranges, ingredients} = parse_input(input)

    trimmed_ranges =
      consolidated_ranges(ranges)
      |> List.to_tuple()

    ingredients
    |> Enum.reduce(0, fn ingredient, acc ->
      case binary_search?(
             trimmed_ranges,
             ingredient,
             0,
             tuple_size(trimmed_ranges) - 1
           ) do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
    {ranges, _} = parse_input(input)
    trimmed_ranges = consolidated_ranges(ranges)

    trimmed_ranges
    |> Enum.reduce(0, fn range, acc ->
      acc + MyRange.size(range)
    end)
  end
end

# def part1(input) do
#  {ranges, ingredients} = parse_input(input)
#
#  sorted_ranges =
#    ranges
#    |> Enum.sort_by(fn x -> x.high end)
#    |> Enum.sort_by(fn x -> x.low end)
#
#  IO.inspect(sorted_ranges)
#
#  sorted_ranges_high_dedup =
#    sorted_ranges
#    |> Enum.dedup_by(fn x -> x.high end)
#    |> List.to_tuple()
#
#  sorted_ranges_low_dedup =
#    sorted_ranges
#    |> Enum.dedup_by(fn x -> x.low end)
#    |> List.to_tuple()
#
#  sorted_ranges_double_dedup =
#    sorted_ranges
#    |> Enum.dedup_by(fn x -> x.low end)
#    |> Enum.dedup_by(fn x -> x.high end)
#    |> List.to_tuple()
#
#  ingredients
#  |> Enum.reduce(0, fn ingredient, acc ->
#    case binary_search?(
#           sorted_ranges_low_dedup,
#           ingredient,
#           0,
#           tuple_size(sorted_ranges_low_dedup) - 1
#         ) or
#           binary_search?(
#             sorted_ranges_high_dedup,
#             ingredient,
#             0,
#             tuple_size(sorted_ranges_high_dedup) - 1
#           ) or
#           binary_search?(
#             sorted_ranges_double_dedup,
#             ingredient,
#             0,
#             tuple_size(sorted_ranges_double_dedup) - 1
#           ) do
#      true -> acc + 1
#      false -> acc
#    end
#  end)
# end
