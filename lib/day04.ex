defmodule Aoc2025.Day04 do
  @directions [{-1, -1}, {-1, 0}, {0, -1}, {0, 1}, {1, -1}, {1, 1}, {1, 0}, {-1, 1}]
  defp input do
    String.trim(File.read!("priv/inputs/day04.txt"))
  end

  def parse_row_into_map(row, row_num, map) do
    graphemes = String.graphemes(row)

    {_, map} = Enum.reduce(graphemes, {0, map}, fn val, {idx, curr_map} ->
      case val do
        "@" -> {idx + 1, Map.put(curr_map, {row_num, idx}, true)}
        "." -> {idx + 1, Map.put(curr_map, {row_num, idx}, false)}
        _ -> {idx + 1, curr_map}
      end
    end)
    map
  end

  def parse_input_into_map(input) do
    {_, map} = input
    |> String.split("\n", trim: true)
    |> Enum.reduce({0, Map.new()}, fn row, {idx, map} ->
      {idx + 1, Map.merge(map, parse_row_into_map(row, idx, map))}
    end)
    map
  end

  def get_sum_of_neighbors({y, x}, map) do
    val = Enum.reduce(@directions, 0, fn {dy, dx}, acc ->
      new_y = y + dy
      new_x = x + dx

      case Map.fetch(map, {new_y, new_x}) do
        :error -> acc
        {:ok, true} -> 1 + acc
        {:ok, false} -> acc
      end
    end)
    val
  end

  def shape(input) do
    rows = String.split(input, "\n", trim: true)
    height = length(rows)
    width = byte_size(List.last(rows))
    {height, width}
  end

  def simulate_row_y(y, row_width, map, threshold\\4) do
    Enum.reduce(0..row_width-1, {0, MapSet.new()}, fn x, {acc, to_remove} ->
      val = cond do
        Map.get(map, {y, x}) -> get_sum_of_neighbors({y, x}, map)
        true -> 9
      end

      cond do
        val < threshold -> {acc + 1, MapSet.put(to_remove, {y, x})}
        true -> {acc, to_remove}
      end
    end)
  end

  def simulate(map, height, width, threshold\\4) do
    Enum.reduce(0..height-1, {0, MapSet.new()}, fn y, {acc, to_remove} ->
      {val, to_remove_additions} = simulate_row_y(y, width, map, threshold)
      {acc + val, MapSet.union(to_remove, to_remove_additions)}
    end)
  end

  def simulate_to_end(map, height, width, running_tot, threshold\\4) do
    {count, to_remove} = simulate(map, height, width, threshold)
    
    case count do
      0 -> running_tot
      _ -> 
        new_map = Map.drop(map, MapSet.to_list(to_remove))
        simulate_to_end(new_map, height, width, running_tot + count)
    end
    
  end

  def part1(), do: part1(input())

  def part1(input) do
    map = parse_input_into_map(input)
    {height, width} = shape(input)
    {count, _} = simulate(map, height, width)
    count
  end

  def part2(), do: part2(input())

  def part2(input) do
    map = parse_input_into_map(input)
    {height, width} = shape(input)
    simulate_to_end(map, height, width, 0)
  end
end
