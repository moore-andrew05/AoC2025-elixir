defmodule Rect do
  @enforce_keys [:x, :y]
  defstruct [
    :x,
    :y
  ]

  def area(rect) do
    rect.x * rect.y
  end
end

defmodule VerticalLine do
  @enforce_keys [:x, :y_range]
  defstruct [
    :x,
    :y_range
  ]
end

defmodule HorizontalLine do
  @enforce_keys [:y, :x_range]
  defstruct [
    :y,
    :x_range
  ]
end

defmodule BetterRect do
  @enforce_keys [:x1, :x2, :y1, :y2, :h_sides, :v_sides, :cp1, :cp2]
  defstruct [
    :x1,
    :x2,
    :y1,
    :y2,
    :h_sides,
    :v_sides,
    :cp1,
    :cp2
  ]

  def new({x1, y1}, {x2, y2}) do
    x_range =
      cond do
        x2 > x1 ->
          x1..x2

        true ->
          x2..x1
      end

    y_range =
      cond do
        y2 > y1 ->
          y1..y2

        true ->
          y2..y1
      end

    %BetterRect{
      x1: x1,
      x2: x2,
      y1: y1,
      y2: y2,
      h_sides: [
        %HorizontalLine{y: y1, x_range: x_range},
        %HorizontalLine{y: y2, x_range: x_range}
      ],
      v_sides: [%VerticalLine{x: x1, y_range: y_range}, %VerticalLine{x: x2, y_range: y_range}],
      cp1: {x1, y2},
      cp2: {x2, y1}
    }
  end

  def area(rect) do
    w = abs(rect.x2 - rect.x1) + 1
    h = abs(rect.y2 - rect.y1) + 1
    w * h
  end
end

defmodule IrregularGridPolygon do
  @enforce_keys [:horizontal_edges, :vertical_edges]
  defstruct [
    :horizontal_edges,
    :vertical_edges
  ]

  defp vertical_intersect(v_edge, h_edge, :seg) do
    cond do
      h_edge.y > v_edge.y_range.first and h_edge.y < v_edge.y_range.last and
        v_edge.x > h_edge.x_range.first and v_edge.x < h_edge.x_range.last ->
        true

      true ->
        false
    end
  end

  defp horizontal_intersect(h_edge, v_edge, :seg) do
    cond do
      v_edge.x > h_edge.x_range.first and v_edge.x < h_edge.x_range.last and
        h_edge.y > v_edge.y_range.first and h_edge.y <v_edge.y_range.last ->
        #IO.puts("Horizontal intersect")
        true

      true ->
        false
    end
  end

  defp horizontal_intersect({x, y}, v_edge) do
    cond do
      v_edge.x == x and y in v_edge.y_range -> -1
      v_edge.x > x and y >= v_edge.y_range.first and y < v_edge.y_range.last -> 1
      true -> 0
    end
  end

  defp validate_vertical_edge(v_edge, polygon) do
    checks = polygon.horizontal_edges

    Enum.reduce_while(checks, true, fn check, acc ->
      case vertical_intersect(v_edge, check, :seg) do
        true -> 
          {:halt, false}
        false -> {:cont, acc}
      end
    end)
  end

  defp validate_horizontal_edge(h_edge, polygon) do
    checks = polygon.vertical_edges

    Enum.reduce_while(checks, true, fn check, acc ->
      case horizontal_intersect(h_edge, check, :seg) do
        true -> {:halt, false}
        false -> {:cont, acc}
      end
    end)
  end

  defp validate_edges(rect, polygon) do
    h = rect.h_sides
    v = rect.v_sides

    Enum.reduce_while(h, true, fn edge, acc ->
      case validate_horizontal_edge(edge, polygon) do
        false -> {:halt, false}
        true -> {:cont, acc}
      end
    end) and
      Enum.reduce_while(v, true, fn edge, acc ->
        case validate_vertical_edge(edge, polygon) do
          false -> {:halt, false}
          true -> {:cont, acc}
        end
      end)
  end

  defp validate_point({x, y}, polygon) do
    checks = polygon.vertical_edges

    tot =
      Enum.reduce_while(checks, 0, fn check, acc ->
        val = horizontal_intersect({x, y}, check)

        cond do
          val == -1 -> {:halt, 1}
          true -> {:cont, acc + val}
        end
      end)

    rem(tot, 2) != 0
  end


  def rect_inside?(polygon, rect) do
    p1_valid = validate_point(rect.cp1, polygon)
    p2_valid = validate_point(rect.cp2, polygon)
    edges_valid = validate_edges(rect, polygon)

    #IO.puts("P1 valid: #{p1_valid}, P2 valid: #{p2_valid}, Edges valid: #{edges_valid}")
    p1_valid and p2_valid and edges_valid
  end
end

defmodule Aoc2025.Day09 do
  defp input do
    String.trim(File.read!("priv/inputs/day09.txt"))
  end

  def pairwise_comparisons(to_compare, idx, curr_max) when idx >= tuple_size(to_compare) - 1 do
    curr_max
  end

  def pairwise_comparisons(to_compare, idx, curr_max) do
    {x1, y1} = elem(to_compare, idx)

    new_max =
      Enum.reduce((idx + 1)..(tuple_size(to_compare) - 1), curr_max, fn comp_idx, iter_max ->
        {x2, y2} = elem(to_compare, comp_idx)
        rect = %Rect{x: abs(x2 - x1) + 1, y: abs(y2 - y1) + 1}

        case Rect.area(rect) do
          area when area > iter_max ->
            area

          _ ->
            iter_max
        end
      end)

    pairwise_comparisons(to_compare, idx + 1, new_max)
  end

  def generate_rectangles_and_area(points, idx, acc) when idx >= tuple_size(points) - 1 do
    acc
  end

  def generate_rectangles_and_area(points, idx, acc) do
    {x1, y1} = elem(points, idx)

    new_acc =
      Enum.reduce((idx + 1)..(tuple_size(points) - 1), acc, fn comp_idx, curr_acc ->
        {x2, y2} = elem(points, comp_idx)
        rect = BetterRect.new({x1, y1}, {x2, y2})
        [{BetterRect.area(rect), rect} | curr_acc]
      end)

    generate_rectangles_and_area(points, idx + 1, new_acc)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [x, y] = String.split(row, ",", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
    |> List.to_tuple()
  end

  def part1(), do: part1(input())

  def part1(input) do
    parsed_input = parse_input(input)

    pairwise_comparisons(parsed_input, 0, 0)
  end

  def part2(), do: part2(input())

  def part2(input) do
    parsed_input =
      parse_input(input)
      |> Tuple.to_list()

    sorted_rectanges =
      parsed_input
      |> List.to_tuple()
      |> generate_rectangles_and_area(0, [])
      |> Enum.sort(:desc)

    edges =
      parsed_input
      |> Enum.chunk_every(2, 1, :discard)

    edges =
      [[List.last(parsed_input), List.first(parsed_input)] | edges]

    {horizontal_edges, vertical_edges} =
      Enum.reduce(edges, {[], []}, fn edge, {h_edges, v_edges} ->
        [{x1, y1}, {x2, y2}] = edge

        cond do
          x1 == x2 and y2 > y1 ->
            v_edge = %VerticalLine{x: x1, y_range: y1..y2}
            {h_edges, [v_edge | v_edges]}

          x1 == x2 and y1 > y2 ->
            v_edge = %VerticalLine{x: x1, y_range: y2..y1}
            {h_edges, [v_edge | v_edges]}

          y1 == y2 and x2 > x1 ->
            h_edge = %HorizontalLine{y: y1, x_range: x1..x2}
            {[h_edge | h_edges], v_edges}

          y1 == y2 and x1 > x2 ->
            h_edge = %HorizontalLine{y: y1, x_range: x2..x1}
            {[h_edge | h_edges], v_edges}
        end
      end)

    polygon = %IrregularGridPolygon{
      horizontal_edges: horizontal_edges,
      vertical_edges: vertical_edges
    }

    Enum.reduce(sorted_rectanges, [], fn rectangle, valid ->
      {area, rect} = rectangle
      # IO.puts("Checking rect of size #{area}")
      # IO.inspect(rect)

      case IrregularGridPolygon.rect_inside?(polygon, rect) do
        true ->
          [{area,rect} | valid]

        false ->
          valid
      end
    end)
    |> List.last()
    |> elem(0)
  end
end
