defmodule Aoc.Elf.Worker do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Process.send_after(self(), :do_work, 0)
    {:ok, state}
  end

  def handle_info(:do_work, state) do
    work(state)
  end

  defp work({step, fin, fin}) do
    Aoc.Elf.Gatherer.done({step, fin})
    {:stop, :normal, nil}
  end

  defp work({step, time, fin}) do
    Process.sleep(1 * 100)
    send(self(), :do_work)
    {:noreply, {step, time + 1, fin}}
  end
end
