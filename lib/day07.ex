defmodule Aoc2025.Day07 do
  defp input do
    String.trim(File.read!("priv/inputs/day07.txt"))
  end

  def get_starting_position("." <> rest, curr_pos) do
    get_starting_position(rest, curr_pos + 1)
  end

  def get_starting_position("S" <> _, curr_pos) do
    curr_pos
  end

  def parse_splitter_positions("^" <> rest, curr_pos, pos_set) do
    parse_splitter_positions(rest, curr_pos + 1, MapSet.put(pos_set, curr_pos))
  end

  def parse_splitter_positions("." <> rest, curr_pos, pos_set) do
    parse_splitter_positions(rest, curr_pos + 1, pos_set)
  end

  def parse_splitter_positions("", _, pos_set) do
    pos_set
  end

  def simulate_splits(beam_positions, splitter_positions) do
    splits = MapSet.intersection(beam_positions, splitter_positions)
    misses = MapSet.difference(beam_positions, splitter_positions)
    num_splits = MapSet.size(splits)

    next_beam_positions =
      Enum.reduce(MapSet.to_list(splits), MapSet.new(), fn hit, new_pos_set ->
        # We don't need to check if we are on the edge just because the data
        # Doesn't include cases like this
        pos_set = MapSet.put(new_pos_set, hit - 1)
        MapSet.put(pos_set, hit + 1)
      end)

    {num_splits, MapSet.union(next_beam_positions, misses)}
  end

  def part1(), do: part1(input())

  def part1(input) do
    [first | rows] =
      input
      |> String.split("\n", trim: true)
      |> Enum.take_every(2)

    starting_pos = get_starting_position(first, 0)

    {total_splits, _} =
      Enum.reduce(rows, {0, MapSet.new([starting_pos])}, fn row, {total_splits, beam_positions} ->
        splitter_positions = parse_splitter_positions(row, 0, MapSet.new())
        {num_splits, next_beam_positions} = simulate_splits(beam_positions, splitter_positions)
        {total_splits + num_splits, next_beam_positions}
      end)

    total_splits
  end

  def memo do
    :ets.new(:dfs_cache, [:named_table, :public])
  end

  def memo_teardown do
    :ets.delete(:dfs_cache)
  end

  def dfs(_, depth, _, max_depth) when depth > max_depth do
    1
  end

  def dfs(pos, depth, splitter_positions, max_depth) do
    splitter_positions_at_depth = elem(splitter_positions, depth)
    case {MapSet.member?(splitter_positions_at_depth, pos), :ets.lookup(:dfs_cache, {pos, depth})} do
      {_, [{_, val}]} ->
        val

      {true, []} ->
        right = dfs(pos + 1, depth + 1, splitter_positions, max_depth) 
        left = dfs(pos - 1, depth + 1, splitter_positions, max_depth)

        :ets.insert(:dfs_cache, {{pos, depth}, right + left})
        right + left


      {false, []} ->
        val = dfs(pos, depth + 1, splitter_positions, max_depth)

        :ets.insert(:dfs_cache, {{pos, depth}, val})
        val
    end
  end

  def part2(), do: part2(input())

  def part2(input) do
    [first | rows] =
      input
      |> String.split("\n", trim: true)
      |> Enum.take_every(2)

    starting_pos = get_starting_position(first, 0)

    splitter_positions =
      rows
      |> Enum.map(&parse_splitter_positions(&1, 0, MapSet.new()))
      |> List.to_tuple()

    memo()
    dfs(starting_pos, 0, splitter_positions, tuple_size(splitter_positions) - 1)
    memo_teardown()
  end
end
