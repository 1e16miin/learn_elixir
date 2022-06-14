defmodule Aoc.Day7 do
  @moduledoc false

  def puzzle_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def parse_instructions(line) do
    regex = ~r/Step (\w) must be finished before step (\w) can begin./
    [_, from, to] = Regex.run(regex, line)
    {from, to}
  end

  def get_all_steps(instructions) do
    instructions
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.concat()
    |> Enum.uniq()
  end

  def get_all_prior_steps(instructions, all_steps) do
    init_all_prior_steps =
      for step <- all_steps, reduce: %{} do
        acc -> Map.put(acc, step, MapSet.new())
      end

    instructions
    |> Enum.reduce(init_all_prior_steps, fn {from, to}, acc ->
      put_in(acc[to], MapSet.put(acc[to], from))
    end)
  end

  def get_workable_steps(all_prior_steps) do
    all_prior_steps
    |> Map.filter(fn {_key, val} -> Enum.count(val) == 0 end)
    |> Map.keys()
    |> Enum.sort()
    |> MapSet.new()
  end

  def get_process_time(step), do: :binary.first(step) - 4

  def update_workers(
        %{workers: workers, time: time},
        num_of_max_workers,
        workable_steps,
        done_steps
      ) do
    filtered_workers =
      workers
      |> Enum.reject(fn %{step: step} -> MapSet.member?(done_steps, step) end)

    num_of_cur_workers = length(filtered_workers)

    new_workers =
      workable_steps
      |> Enum.take(num_of_max_workers - num_of_cur_workers)
      |> Enum.map(fn step ->
        %{step: step, end_time: time + get_process_time(step)}
      end)

    Enum.concat(filtered_workers, new_workers)
  end

  def update_prior_steps(prior_steps, working_stpes) do
    prior_steps
    |> MapSet.difference(working_stpes)
  end

  def update_all_prior_steps(all_prior_steps, done_steps, workers) do
    working_stpes =
      workers
      |> Enum.map(fn %{step: step} -> step end)
      |> MapSet.new()

    for {step, prior_steps} <- all_prior_steps, reduce: %{} do
      acc -> Map.put(acc, step, update_prior_steps(prior_steps, done_steps))
    end
    |> Map.reject(fn {step, _prior_steps} -> MapSet.member?(working_stpes, step) end)
  end

  def create_init_state(all_prior_steps, num_of_max_workers) do
    init_all_prior_steps = update_all_prior_steps(all_prior_steps, MapSet.new(), [])
    workable_steps = get_workable_steps(init_all_prior_steps)

    init_workers =
      update_workers(%{workers: [], time: -1}, num_of_max_workers, workable_steps, MapSet.new())

    %{}
    |> Map.put(:time, -1)
    |> Map.put(:orders, [])
    |> Map.put(:all_prior_steps, init_all_prior_steps)
    |> Map.put(:workers, init_workers)
  end

  def get_done_steps(workers, time) do
    workers
    |> Enum.filter(fn %{end_time: end_time} -> end_time == time end)
    |> Enum.map(fn %{step: step} -> step end)
    |> MapSet.new()
  end

  def work(
        %{orders: orders, all_prior_steps: all_prior_steps, workers: workers, time: time} = state,
        num_of_max_workers
      ) do
    state

    done_steps = get_done_steps(workers, time)

    updated_prior_steps = update_all_prior_steps(all_prior_steps, done_steps, workers)

    workable_steps = get_workable_steps(updated_prior_steps)

    updated_workers = update_workers(state, num_of_max_workers, workable_steps, done_steps)

    updated_orders = Enum.concat(orders, done_steps)

    state
    |> Map.replace(:time, time + 1)
    |> Map.replace(:orders, updated_orders)
    |> Map.replace(:all_prior_steps, updated_prior_steps)
    |> Map.replace(:workers, updated_workers)
  end

  def get_orders(all_prior_steps, num_of_max_workers) do
    init_state = create_init_state(all_prior_steps, num_of_max_workers)

    init_state
    |> Stream.iterate(&work(&1, num_of_max_workers))
    |> Stream.drop_while(fn %{workers: workers} -> Enum.any?(workers) end)
    |> Enum.take(1)
    |> List.first()
  end

  def part2(num_of_max_workers) do
    instructions =
      "../../resources/day7.txt"
      |> puzzle_input()
      |> Enum.map(&parse_instructions/1)

    all_steps = get_all_steps(instructions)

    all_prior_steps = get_all_prior_steps(instructions, all_steps)

    get_orders(all_prior_steps, num_of_max_workers)
    |> Map.get(:time)
    |> IO.inspect()
  end
end

Aoc.Day7.part2(5)
