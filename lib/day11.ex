defmodule Aoc2025.Day11 do
  @start_node "you"
  @end_node "out"
  @max_depth 15
  def memo do
    :ets.new(:dfs_cache, [:named_table, :public])
  end

  def memo_teardown do
    :ets.delete(:dfs_cache)
  end

  defp input do
    String.trim(File.read!("priv/inputs/day11.txt"))
  end

  def parse_input_into_graph([], map) do
    map
  end

  def parse_input_into_graph([entry | rest], map) do
    [key, values] = String.split(entry, ":", trim: true)

    parse_input_into_graph(rest, Map.put(map, key, String.split(values, " ", trim: true)))
  end

  def find_n_unique_paths(node, _, _, end_node, _, _, _, :p1) when node == end_node do
    1
  end

  def find_n_unique_paths(node, _, _, end_node, dac_visited, fft_visited, _, :p2)
      when node == end_node do
    if dac_visited and fft_visited do
      1
    else
      0
    end
  end

  def find_n_unique_paths(node, depth, graph, end_node, dac_visited, fft_visited, visited, part) do
    val =
      case {:ets.lookup(:dfs_cache, {node, depth}), MapSet.member?(visited, node) or depth > @max_depth} do
        {_, true} ->
          0

        {[{_, val}], _} ->
          val

        {[], false} ->
          neighbors = graph[node]

          Enum.reduce(neighbors, 0, fn neighbor, acc ->
            val =
              find_n_unique_paths(
                neighbor,
                depth + 1,
                graph,
                end_node,
                node == "dac" or dac_visited,
                node == "fft" or fft_visited,
                MapSet.put(visited, node),
                part
              )

            acc + val
          end)
      end

    :ets.insert(:dfs_cache, {{node, depth+1}, val})
    val
  end

  def part1(), do: part1(input())

  def part1(input) do
    graph =
      input
      |> String.split("\n", trim: true)
      |> parse_input_into_graph(Map.new())

    memo()
    val = find_n_unique_paths("svr", 0, graph, @end_node, false, false, MapSet.new(), :p1)
    memo_teardown()
    val
  end

  def part2(), do: part2(input())

  def part2(input) do
    graph =
      input
      |> String.split("\n", trim: true)
      |> parse_input_into_graph(Map.new())

    memo()
    val = find_n_unique_paths("svr", 0, graph, @end_node, false, false, MapSet.new(), :p2)
    memo_teardown()
    val
  end
end
