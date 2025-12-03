defmodule Aoc2025.Day03 do
  defp input do
    String.trim(File.read!("priv/inputs/day03.txt"))
  end

  def get_idx_of_max(_, curr_max, curr_idx, i, len) when i >= len do
    {curr_max, curr_idx}
  end

  def get_idx_of_max(arr, curr_max, curr_idx, i, len) do
    val = elem(arr, i)

    case val do
      x when x > curr_max ->
        get_idx_of_max(arr, val, i, i + 1, len)

      _ ->
        get_idx_of_max(arr, curr_max, curr_idx, i + 1, len)
    end
  end

  def max_two_sum_ish(arr, len) do
    {_, val} =
      Enum.reduce((len - 1)..0//-1, {0, 0}, fn pos, {idx, acc} ->
        {val, left_idx} = get_idx_of_max(arr, 0, 0, idx, tuple_size(arr) - pos)
        {left_idx + 1, acc + val * 10 ** pos}
      end)

    val
  end

  defp convert_graphemes_to_int(arr) do
    Enum.map(arr, &String.to_integer(&1))
    |> List.to_tuple()
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes(&1))
    |> Enum.map(&convert_graphemes_to_int(&1))
  end

  def part1(), do: part1(input())

  def part1(input) do
    parse_input(input)
    |> Enum.reduce(0, fn bank, acc ->
      acc + max_two_sum_ish(bank, 2)
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
    parse_input(input)
    |> Enum.reduce(0, fn bank, acc ->
      acc + max_two_sum_ish(bank, 12)
    end)
  end
end
