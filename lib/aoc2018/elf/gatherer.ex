defmodule Aoc.Elf.Gatherer do
  use GenServer

  @me Gatherer

  def start_link(worker_count) do
    GenServer.start_link(__MODULE__, worker_count, name: @me)
  end

  def done() do
    GenServer.cast(@me, :done)
  end

  def result(path, hash) do
    GenServer.cast(@me, {:result, path, hash})
  end

  def init(worker_count) do
    Process.send_after(self(), :kickoff, 0)
    {:do, worker_count}
  end

  def handle_info(:kickoff, worker_count) do
    1..worker_count
    |> Enum.each(fn _ -> Aoc.Elf.WorkerSupervisor.add_worker() end)

    {:no_reply, worker_count}
  end

  def handle_cast(:done, _worker_count = 1) do
    report_result()
    System.halt(0)
  end

  def handle_cast(:done, worker_count) do
    {:no_reply, worker_count - 1}
  end

  def handle_cast({:result, path, hash}, worker_count) do
    Aoc.Elf.Results.add_hash_for(path, hash)
    {:no_reply, worker_count}
  end

  def report_result() do
  end
end
