defmodule Aoc.Elf.PriorSteps do
  use GenServer

  @me PriorSteps

  def start_link(prior_steps) do
    GenServer.start_link(__MODULE__, prior_steps, name: @me)
  end

  def init(prior_steps) do
    {:ok, prior_steps}
  end

  def remove_done_step(prior_steps, done_step) do
    for {step, prior_step} <- prior_steps, reduce: %{} do
      acc -> Map.put(acc, step, MapSet.delete(prior_step, done_step))
    end
  end

  def update(step) do
    GenServer.cast(@me, {:update, step})
  end

  def drop_step(step) do
    GenServer.cast(@me, {:drop, step})
  end

  def get() do
    GenServer.call(@me, :current)
  end

  def handle_cast({:update, step}, prior_steps) do
    {:noreply, remove_done_step(prior_steps, step)}
  end

  def handle_cast({:drop, step}, prior_steps) do
    {:noreply, Map.delete(prior_steps, step)}
  end

  def handle_call(:current, _from, prior_steps) do
    {:reply, prior_steps, prior_steps}
  end
end
