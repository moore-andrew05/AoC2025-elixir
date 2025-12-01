defmodule Aoc2025.Day01 do
  @dial_size 100
  defp input do
    String.trim(File.read!("priv/inputs/day01.txt"))
  end

  defp update_position(curr_position, "R" <> mag) do
    mag = String.to_integer(mag)
    update = mag + curr_position
    num_zeros = floor(update / @dial_size)
    {rem(update, @dial_size), num_zeros}
  end

  defp update_position(curr_position, "L" <> mag) do
    mag = String.to_integer(mag)
    update = curr_position - mag
    new_pos = rem(update, @dial_size)
    num_zeros = case curr_position do
      0 -> -ceil(update / @dial_size)
      _ -> -floor(update / @dial_size)
    end

    cond do
      new_pos > 0 -> {new_pos, num_zeros}
      new_pos == 0 -> {new_pos, num_zeros + 1}
      true -> {@dial_size + new_pos, num_zeros}
    end
  end

  def part1(), do: part1(input())

  def part1(input) do
    moves = input |> String.split("\n", trim: true)

    Enum.reduce(moves, {50, 0}, fn move, {pos, count} ->
      {updated_position, _} = update_position(pos, move)

      cond do
        updated_position == 0 -> {updated_position, count + 1}
        true -> {updated_position, count}
      end
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
    moves = input |> String.split("\n", trim: true)

    Enum.reduce(moves, {50, 0}, fn move, {pos, count} ->
      {updated_position, zeros} = update_position(pos, move)

      {updated_position, count + zeros}
    end)
  end
end
