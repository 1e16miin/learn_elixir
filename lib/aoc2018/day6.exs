defmodule Aoc.Day6 do
  def puzzle_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end

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

  def get_boundary(starting_points) do
    [{x_min, x_max}, {y_min, y_max}] =
      starting_points
      |> Enum.unzip()
      |> Tuple.to_list()
      |> Enum.map(&Enum.min_max/1)

    {x_min, y_min, x_max, y_max}
  end

  def parse_dist_starting_point_point(starting_point, point),
  do: {manhattan_distance(starting_point, point), starting_point, point}

  def get_nearest_starting(point, starting_points) do
    min_distance =
      starting_points
      |> Enum.map(&manhattan_distance(&1, point))
      |> Enum.min()

    starting_points
    |> Enum.map(&parse_dist_starting_point_point(&1, point))
    |> Enum.filter(fn {dist, _starting_point, _point} -> dist == min_distance end)
  end

  def get_finite_area(boundary, starting_points) do
    boundary
    |> inner_points()
    |> Enum.map(&get_nearest_starting(&1, starting_points))
    |> Enum.reject(fn point_dist_list -> Enum.count(point_dist_list) > 1 end)
    |> Enum.map(fn [{_dist, starting_point, point}] -> {starting_point, point} end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  def part1(filename) do
    starting_points =
      filename
      |> puzzle_input()
      |> Enum.map(&parse_coords/1)

    {x_min, y_min, x_max, y_max} = boundary = get_boundary(starting_points)

    boundary
    |> get_finite_area(starting_points)
    |> Enum.reject(fn {{x, y}, fields} ->
      Enum.any?([{x_min, y}, {x_max, y}, {x, y_min}, {x, y_max}], &(&1 in fields)) end)
    |> Enum.map(fn {_, fields} -> length(fields) end)
    |> Enum.max()
    |> IO.puts()
  end

  def sum_of_manhattan_distance(point, starting_points) do
    starting_points
    |> Enum.map(&manhattan_distance(&1, point))
    |> Enum.sum()
  end

  def part2(filename) do
    starting_points =
      filename
      |> puzzle_input()
      |> Enum.map(&parse_coords/1)

    boundary = get_boundary(starting_points)

    boundary
    |> inner_points()
    |> Enum.map(&sum_of_manhattan_distance(&1, starting_points))
    |> Enum.reject(fn size -> size >= 10000 end)
    |> Enum.count()
    |> IO.puts()
  end
end

Aoc.Day6.part1("../../resources/day6.txt")
