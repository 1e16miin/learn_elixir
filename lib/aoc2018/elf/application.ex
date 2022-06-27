defmodule Aoc.Elf.Application do
  use Application

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

  def get_prior_steps(instructions) do
    all_steps = get_all_steps(instructions)

    init_prior_steps =
      for step <- all_steps, reduce: %{} do
        acc -> Map.put(acc, step, MapSet.new())
      end

    instructions
    |> Enum.reduce(init_prior_steps, fn {from, to}, acc ->
      put_in(acc[to], MapSet.put(acc[to], from))
    end)
  end

  def start(_type, _args) do
    prior_steps =
      "resources/day7.txt"
      |> puzzle_input()
      |> Enum.map(&parse_instructions/1)
      |> get_prior_steps()

    children = [
      Aoc.Elf.Results,
      {Aoc.Elf.PriorSteps, prior_steps},
      Aoc.Elf.WorkerSupervisor,
      Aoc.Elf.Gatherer
    ]

    opts = [strategy: :one_for_all, name: Aoc.Elf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
