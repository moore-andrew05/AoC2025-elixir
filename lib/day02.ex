defmodule Aoc2025.Day02 do
  defp input do
    String.trim(File.read!("priv/inputs/day02.txt"))
  end

  def invalid_id_sum([low, high])
      when rem(byte_size(low), 2) != 0 and rem(byte_size(high), 2) == 0 do
    half = div(byte_size(high), 2)
    high_slice = binary_slice(high, 0, half)
    high_bound = String.to_integer(high_slice)
    low_bound = 10 ** (byte_size(high_slice) - 1)
    include_high = String.to_integer(binary_slice(high, half, byte_size(high))) >= high_bound

    high_bound =
      case include_high do
        true -> high_bound
        false -> high_bound - 1
      end

    Enum.reduce(low_bound..high_bound, 0, fn curr, acc ->
      curr_str = Integer.to_string(curr)
      acc + String.to_integer(curr_str <> curr_str)
    end)
  end

  def invalid_id_sum([low, high])
      when rem(byte_size(low), 2) == 0 and rem(byte_size(high), 2) != 0 do
    half = div(byte_size(low), 2)
    low_slice = binary_slice(low, 0, half)
    low_bound = String.to_integer(low_slice)
    high_bound = 10 ** byte_size(low_slice)
    include_low = String.to_integer(binary_slice(low, half, byte_size(low))) <= low_bound

    low_bound =
      case include_low do
        true -> low_bound
        false -> low_bound + 1
      end

    Enum.reduce(low_bound..(high_bound - 1), 0, fn curr, acc ->
      curr_str = Integer.to_string(curr)
      acc + String.to_integer(curr_str <> curr_str)
    end)
  end

  def invalid_id_sum([low, high])
      when rem(byte_size(low), 2) == 0 and rem(byte_size(high), 2) == 0 do
    half = div(byte_size(low), 2)
    low_slice = binary_slice(low, 0, half)
    low_bound = String.to_integer(low_slice)
    high_slice = binary_slice(high, 0, half)
    high_bound = String.to_integer(high_slice)
    include_low = String.to_integer(binary_slice(low, half, byte_size(low))) <= low_bound
    include_high = String.to_integer(binary_slice(high, half, byte_size(high))) >= high_bound

    low_bound =
      case include_low do
        true -> low_bound
        false -> low_bound + 1
      end

    high_bound =
      case include_high do
        true -> high_bound
        false -> high_bound - 1
      end

    cond do
      low_slice == high_slice and (include_low and include_high) ->
        String.to_integer(low_slice <> low_slice)

      low_slice == high_slice ->
        0

      true ->
        Enum.reduce(low_bound..high_bound, 0, fn curr, acc ->
          curr_str = Integer.to_string(curr)
          acc + String.to_integer(curr_str <> curr_str)
        end)
    end
  end

  def invalid_id_sum([low, high])
      when rem(byte_size(low), 2) != 0 and rem(byte_size(high), 2) != 0 do
    0
  end

  def part1(), do: part1(input())

  def part1(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(0, fn id, acc ->
      id_sum = invalid_id_sum(id)
      acc + id_sum
    end)
  end

  def get_factors(1) do
    []
  end

  def get_factors(num) do
    Enum.reduce(1..(num - 1), [], fn i, factors ->
      case rem(num, i) do
        0 -> [i | factors]
        _ -> factors
      end
    end)
  end

  def is_invalid?(num, segment_size) do
    num_segments = div(byte_size(num), segment_size)

    seen =
      Enum.reduce(0..(num_segments - 1), MapSet.new(), fn starting_idx, seen ->
        curr_seg = binary_slice(num, starting_idx * segment_size, segment_size)
        MapSet.put(seen, curr_seg)
      end)

    case MapSet.size(seen) do
      1 -> true
      _ -> false
    end
  end

  def invalid_single_point_sum(num) do
    factors = get_factors(byte_size(num))

    Enum.reduce_while(factors, 0, fn factor, tot ->
      case is_invalid?(num, factor) do
        true -> 
          {:halt, String.to_integer(num)}
        false -> {:cont, tot}
      end
    end)
  end

  def invalid_in_range_sum([low, high]) do
    low_bound = String.to_integer(low)
    high_bound = String.to_integer(high)

    Enum.reduce(low_bound..high_bound, 0, fn num, acc ->
      acc + invalid_single_point_sum(Integer.to_string(num))
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(0, fn x, acc ->
      acc + invalid_in_range_sum(x)
    end)
  end
end
