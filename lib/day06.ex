defmodule Aoc2025.Day06 do
  defp input do
    String.trim(File.read!("priv/inputs/day06.txt"))
  end

  def process_numerical_row(row) do
    String.split(row, " ", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def process_operator_row(row) do
    String.split(row, " ", trim: true)
  end

  def operate({"+", a, b, c, d}) do
    a + b + c + d
  end

  def operate({"*", a, b, c, d}) do
    a * b * c * d
  end

  def part1(), do: part1(input())

  def part1(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.reverse()

    [operators | numbers] = rows

    operators = process_operator_row(operators)

    numbers =
      numbers
      |> Enum.map(&process_numerical_row(&1))

    Enum.zip([operators | numbers])
    |> Enum.reduce(0, fn x, acc ->
      acc + operate(x)
    end)
  end

  def get_int_from_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.join()
    |> String.trim()
    |> String.to_integer()
  end

  def get_ints_from_chunk(chunk) do
    chunk
    |> Enum.map(&get_int_from_tuple(&1))
  end

  def chunk_rows(rows) do
    chunked =
      rows
      |> Enum.map(&String.graphemes(&1))
      |> Enum.zip()
      |> Enum.chunk_by(&(&1 == {" ", " ", " ", " "}))
      |> Enum.take_every(2)

    chunked
    |> Enum.map(&get_ints_from_chunk(&1))
  end

  def part2(), do: part2(input())

  def part2(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.reverse()

    [operators | numbers] = rows

    operators = process_operator_row(operators)

    numbers =
      numbers
      |> Enum.reverse()
      |> chunk_rows()

    Enum.zip(operators, numbers)
    |> Enum.reduce(0, fn x, acc ->
      case x do
        {"+", nums} -> acc + Enum.sum(nums)
        {"*", nums} -> acc + Enum.product(nums)
      end
    end)
  end
end
