defmodule Aoc2025.Day12 do
  @sizes [5, 7, 7, 7, 6, 7]
  defp input do
    String.trim(File.read!("priv/inputs/day12.txt"))
  end

  def check(row) do
    [size, vals] = row

    size =
      size
      |> String.split("x", trim: true)
      |> Enum.map(&String.to_integer(&1))
      |> Enum.product()

    pieces_size =
      vals
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer(&1))
      |> Enum.zip(@sizes)
      |> Enum.reduce(0, fn x, acc ->
        acc + elem(x, 0) * elem(x, 1)
      end)

    size > pieces_size
  end

  def part1(), do: part1(input())

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(&check(&1))
    |> Enum.reduce(0, fn x, acc ->
      case x do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
  end
end

