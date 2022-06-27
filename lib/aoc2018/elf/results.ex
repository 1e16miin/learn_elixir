defmodule Aoc.Elf.Results do
  use GenServer

  @me Results

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  def add(step) do
    GenServer.cast(@me, {:add, step})
  end

  def result(time) do
    GenServer.call(@me, {:result, time})
  end

  def init(:no_args) do
    {:ok, []}
  end

  def handle_cast({:add, step}, orders) do
    {:noreply, [step | orders]}
  end

  def handle_call({:result, time}, _from, orders) when length(orders) == 26 do
    IO.inspect({time, Enum.reverse(orders)})
    System.halt(0)
  end

  def handle_call({:result, _time}, _from, orders) do
    {:reply, Enum.reverse(orders), orders}
  end
end
