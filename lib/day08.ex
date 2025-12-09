defmodule JBox do
  @enforce_keys [:x, :y, :z, :id]
  defstruct [
    :x,
    :y,
    :z,
    :id
  ]

  def parse_row(row, id) do
    [x, y, z] =
      String.split(row, ",", trim: true)
      |> Enum.map(&String.to_integer(&1))

    %JBox{x: x, y: y, z: z, id: id}
  end
end

defmodule Pair do
  @enforce_keys [:jbox1, :jbox2]
  defstruct [
    :jbox1,
    :jbox2
  ]

  def euclidean_distance(pair) do
    %Pair{jbox1: jbox1, jbox2: jbox2} = pair
    ((jbox1.x - jbox2.x) ** 2 + (jbox1.y - jbox2.y) ** 2 + (jbox1.z - jbox2.z) ** 2) ** 0.5
  end
end

defmodule KHeap do
  defstruct [
    :heap,
    :k
  ]

  def new(k) do
    %KHeap{heap: Heap.max(), k: k}
  end

  def heappush(kheap, element) do
    new_heap = Heap.push(kheap.heap, element)

    new_heap =
      if Heap.size(new_heap) > kheap.k do
        Heap.pop(new_heap)
      else
        new_heap
      end

    %KHeap{heap: new_heap, k: kheap.k}
  end
end

defmodule Aoc2025.Day08 do
  defp input do
    String.trim(File.read!("priv/inputs/day08.txt"))
  end

  def do_pairwise_comparisons(boxes, idx, kheap) when idx >= tuple_size(boxes) - 1 do
    kheap
  end

  def do_pairwise_comparisons(boxes, idx, kheap) do
    from_jbox = elem(boxes, idx)

    Enum.reduce((idx + 1)..(tuple_size(boxes) - 1), kheap, fn to_jbox_idx, curr_heap ->
      to_jbox = elem(boxes, to_jbox_idx)
      pair = %Pair{jbox1: from_jbox, jbox2: to_jbox}

      dist =
        pair
        |> Pair.euclidean_distance()

      KHeap.heappush(curr_heap, {dist, pair})
    end)
  end

  def merge_clusters(id1, id2, clusters, cluster_directory) do
    cluster_id1 = Map.get(clusters, id1)
    cluster_id2 = Map.get(clusters, id2)

    new_cluster_list =
      cluster_directory[cluster_id1] ++ cluster_directory[cluster_id2]

    updated_clusters =
      Enum.reduce(new_cluster_list, clusters, fn id, curr_clusters ->
        Map.put(curr_clusters, id, cluster_id1)
      end)

    updated_cluster_directory =
      Map.put(cluster_directory, cluster_id1, new_cluster_list)
      |> Map.delete(cluster_id2)

    {updated_clusters, updated_cluster_directory}
  end

  def try_merge_clusters(id1, id2, clusters, cluster_directory) do
    cluster1 = Map.get(clusters, id1)
    cluster2 = Map.get(clusters, id2)

    case cluster1 == cluster2 do
      true ->
        {clusters, cluster_directory}

      false ->
        merge_clusters(id1, id2, clusters, cluster_directory)
    end
  end

  def build_clusters(heap, clusters, cluster_directory, new_cluster_num, max_circuit_size) do
    {{_, pair}, rest} = Heap.split(heap)
    %Pair{jbox1: jbox1, jbox2: jbox2} = pair

    {new_clusters, new_cluster_directory, new_new_cluster_num} =
      case {Map.has_key?(clusters, jbox1.id), Map.has_key?(clusters, jbox2.id)} do
        {true, true} ->
          {c, d} =
            try_merge_clusters(
              jbox1.id,
              jbox2.id,
              clusters,
              cluster_directory
            )

          {c, d, new_cluster_num}

        {true, false} ->
          cluster = Map.get(clusters, jbox1.id)

          {Map.put(clusters, jbox2.id, cluster),
           Map.update!(cluster_directory, cluster, fn x -> x ++ [jbox2.id] end), new_cluster_num}

        {false, true} ->
          cluster = Map.get(clusters, jbox2.id)

          {Map.put(clusters, jbox1.id, cluster),
           Map.update!(cluster_directory, cluster, fn x -> x ++ [jbox1.id] end), new_cluster_num}

        {false, false} ->
          updated_clusters =
            Map.put(clusters, jbox1.id, new_cluster_num)
            |> Map.put(jbox2.id, new_cluster_num)

          updated_cluster_directory =
            Map.put(cluster_directory, new_cluster_num, [jbox1.id, jbox2.id])

          {updated_clusters, updated_cluster_directory, new_cluster_num + 1}
      end

    found_last =
      map_size(new_cluster_directory) == 1 and
        length(List.first(Map.values(new_cluster_directory))) == max_circuit_size

    cond do
      found_last ->
        jbox1.x * jbox2.x

      Heap.empty?(rest) ->
        new_clusters

      true ->
        build_clusters(
          rest,
          new_clusters,
          new_cluster_directory,
          new_new_cluster_num,
          max_circuit_size
        )
    end
  end

  def parse_clusters(input, k) do
    to_compare =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {value_str, id} -> JBox.parse_row(value_str, id) end)
      |> List.to_tuple()

    kheap = KHeap.new(k)

    top_k_pairs =
      Enum.reduce(0..(tuple_size(to_compare) - 1), kheap, fn curr_idx, curr_heap ->
        do_pairwise_comparisons(to_compare, curr_idx, curr_heap)
      end)
    {top_k_pairs, tuple_size(to_compare)}

  end


  # 1000 connections
  def part1(), do: part1(input(), 1000)

  def part1(input, k) do
    {top_k_pairs, max_size} = parse_clusters(input, k)

    build_clusters(top_k_pairs.heap, Map.new(), Map.new(), 1, max_size)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end


  def move_max_heap_to_min(max_heap) do
    move_max_heap_to_min(max_heap, Heap.min())
  end

  def move_max_heap_to_min(max_heap, min_heap) do
    {{dist, pair}, rest} = Heap.split(max_heap)

    case Heap.empty?(rest) do
      true ->
        Heap.push(min_heap, {dist, pair})
      false ->
        move_max_heap_to_min(rest, Heap.push(min_heap, {dist, pair}))
    end
  end

  def part2(), do: part2(input(), 1_000_000)

  def part2(input, k) do
    {top_k_pairs, max_size} = parse_clusters(input, k)
    move_max_heap_to_min(top_k_pairs.heap)
    |> build_clusters(Map.new(), Map.new(), 1, max_size)
  end
end
