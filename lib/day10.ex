defmodule Button do
  @enforce_keys [:nums]
  defstruct [
    :nums
  ]
end

defmodule Machine do
  @enforce_keys [:desired_state, :current_state, :buttons, :num_buttons]
  defstruct [
    :desired_state,
    :current_state,
    :buttons,
    :num_buttons
  ]

  def press_button(machine, idx) do
    button = elem(machine.buttons, idx)

    new_state =
      Enum.reduce(button.nums, machine.current_state, fn num, state ->
        curr_val = elem(state, num)
        put_elem(state, num, not curr_val)
      end)

    %Machine{
      desired_state: machine.desired_state,
      current_state: new_state,
      buttons: machine.buttons,
      num_buttons: machine.num_buttons
    }
  end

  def reached_desired_state?(machine) do
    machine.desired_state == machine.current_state
  end
end

defmodule Aoc2025.Day10 do
  @row_regex ~r"\[(?<desired_state>\W+)\] (?<buttons>.+) {(?<part2_maybe>.+)}"
  @button_regex ~r"\((.+)\)"
  defp input do
    String.trim(File.read!("priv/inputs/day10.txt"))
  end

  def convert_row_str_to_int(row) do
    row
    |> Enum.map(&String.to_integer(&1))
  end

  def parse_buttons_from_string(button_str) do
    button_str
    |> String.split(" ", trim: true)
    |> Enum.map(&(Regex.scan(@button_regex, &1) |> List.last() |> List.last()))
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Enum.map(fn x ->
      int_vals = convert_row_str_to_int(x)
      %Button{nums: int_vals}
    end)
  end

  def parse_row_into_machine(row) do
    groups = Regex.named_captures(@row_regex, row)

    desired_state =
      groups["desired_state"]
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.reduce([], fn x, acc ->
        case x do
          "#" -> [true | acc]
          "." -> [false | acc]
        end
      end)
      |> List.to_tuple()

    buttons = parse_buttons_from_string(groups["buttons"]) |> List.to_tuple()
    num_buttons = tuple_size(buttons)

    initial_state =
      Enum.reduce(1..tuple_size(desired_state), [], fn _, n ->
        [false | n]
      end)
      |> List.to_tuple()

    %Machine{
      desired_state: desired_state,
      current_state: initial_state,
      buttons: buttons,
      num_buttons: num_buttons
    }
  end

  def minimize_machine(queue, seen) do
    case :queue.out(queue) do
      {:empty, _} ->
        {:done, :none_found}

      {{:value, {machine, button_presses}}, rest} ->
        case Machine.reached_desired_state?(machine) do
          true ->
            button_presses

          _ ->
            {new_queue, new_seen} =
              Enum.reduce(0..(machine.num_buttons - 1), {rest, seen}, fn x, {r, s} ->
                new_machine = Machine.press_button(machine, x)
                case MapSet.member?(seen, new_machine.current_state) do
                  true -> 
                    {r, s}
                  _ -> 
                    ns = MapSet.put(s, new_machine.current_state)
                    {:queue.in({new_machine, button_presses + 1}, r), ns}
                end
              end)
            minimize_machine(new_queue, new_seen)
        end
    end
  end

  def part1(), do: part1(input())

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row_into_machine(&1))
    |> Enum.reduce(0, fn x, acc ->
       acc + minimize_machine(:queue.from_list([{x, 0}]), MapSet.new())
    end)
  end

  def part2(), do: part2(input())

  def part2(input) do
  end
end
