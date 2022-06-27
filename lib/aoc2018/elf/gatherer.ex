defmodule Aoc.Elf.Gatherer do
  use GenServer

  @me Gatherer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  # update_prior_steps
  def done({step, time}) do
    Aoc.Elf.PriorSteps.update(step)
    GenServer.cast(@me, {:done, step, time})
  end

  def result() do
    GenServer.call(@me, :result)
  end

  def get_process_time(step), do: :binary.first(step) - 4

  def init(:no_args) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, {0, 0}}
  end

  def get_workable_steps(prior_steps) do
    prior_steps
    |> Map.filter(fn {_key, val} -> Enum.count(val) == 0 end)
    |> Map.keys()
    |> Enum.sort()
  end

  def create_new_workers(worker_count = 5, _start, []), do: worker_count

  def create_new_workers(worker_count, _start, []), do: worker_count

  def create_new_workers(worker_count = 5, _start, [_step | _waiting]), do: worker_count

  def create_new_workers(worker_count, start, [step | waitings]) do
    Aoc.Elf.WorkerSupervisor.add_worker({step, start, start + get_process_time(step)})
    Aoc.Elf.PriorSteps.drop_step(step)
    create_new_workers(worker_count + 1, start, waitings)
  end

  def handle_info(:kickoff, {worker_count, time}) do
    workable_steps =
      Aoc.Elf.PriorSteps.get()
      |> get_workable_steps()

    new_worker_count = create_new_workers(worker_count, time, workable_steps)
    {:noreply, {new_worker_count, time}}
  end

  def handle_cast({:done, step, time}, {worker_count, _time}) do
    Aoc.Elf.Results.add(step)
    Aoc.Elf.Results.result(time)
    IO.inspect(Aoc.Elf.PriorSteps.get())

    workable_steps =
      Aoc.Elf.PriorSteps.get()
      |> get_workable_steps()

    new_worker_count = create_new_workers(worker_count - 1, time, workable_steps)
    {:noreply, {new_worker_count, time}}
  end
end
