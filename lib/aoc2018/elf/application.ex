defmodule Aoc.Elf.Application do
  use Application

  def start(_type, _args) do
    children = [
      Aoc.Elf.Results,
      {Aoc.Elf.State, %{}},
      Aoc.Elf.WorkerSupervisor,
      {Aoc.Elf.Gatherer, 1}
    ]

    opts = [strategy: :one_for_all, name: Aoc.Elf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
