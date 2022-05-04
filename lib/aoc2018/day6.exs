# defmodule Aoc.Utils do

# end

defmodule Aoc.Day6 do
  def puzzle_input(file) do
    file
    |> String.split("\n", trim: true)
  end

  # def insert_landmarks([], map, _), do: map

  # def insert_landmarks([head | tail], map, id) do
  #   coords = parse_coords(head)
  #   insert_landmarks(tail, Map.put(map, coords, id), id + 1)
  # end

  def parse_coords(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def inner_points({x1, y1, x2, y2}) do
    for x <- (x1 - 1)..(x2 + 1), y <- (y1 - 1)..(y2 + 1), do: {x, y}
  end

  def manhattan_distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def get_boundary([{x, y} | list]) do
    Enum.reduce(list, {x, y, x, y}, fn {x, y}, {x1, y1, x2, y2} ->
      {min(x, x1), min(y, y1), max(x, x2), max(y, y2)}
    end)
  end

  def part1(filename) do
    points =
      filename
      |> File.read!()
      |> puzzle_input()
      |> Enum.map(&parse_coords/1)

    {x1, y1, x2, y2} = boundary = get_boundary(points)
    # IO.puts(bounding)

    boundary
    |> inner_points()
    |> Enum.flat_map(fn position ->
      points
      |> Enum.reduce(nil, fn
        point, nil ->
          {manhattan_distance(position, point), [point]}

        point, old = {distance, points} ->
          new_distance = manhattan_distance(position, point)

          cond do
            distance < new_distance -> old
            distance == new_distance -> {distance, [point | points]}
            distance > new_distance -> {new_distance, [point]}
          end
      end)
      |> case do
        {_dist, [center]} -> [{center, position}]
        {_dist, _} -> []
      end
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.reject(fn {{x, y}, fields} ->
      Enum.any?([{x1 - 1, y}, {x2 + 1, y}, {x, y1 - 1}, {x, y2 + 1}], &(&1 in fields))
    end)
    |> Enum.map(fn {_, fields} -> length(fields) end)
    |> Enum.max()
    |> IO.puts()
  end
end

Aoc.Day6.part1("../../resources/day6.test.txt")
