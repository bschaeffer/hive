defmodule Hive.Worker do
  use GenServer
  require Logger

  def get_name(pid) do
    GenServer.call(pid, {:name})
  end

  def raise(pid, msg) do
    GenServer.cast(pid, {:raise, msg})
  end

  def register(name) do
    {:ok, _pid} = start_link(name)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [name], name: name)
  end

  def init([name]) do
    Hive.Registry.monitor(self(), name)
    {:ok, name}
  end

  def handle_cast({:raise, msg}, _name) do
    raise msg
  end

  def handle_call({:name}, _from, name) do
    {:reply, name, name}
  end

  def handle_call({:swarm, :begin_handoff}, _from, name) do
    Logger.info("[Worker] begin_handoff: #{name}")
    {:reply, :resume, name}
  end

  def handle_cast({:swarm, :end_handoff}, name) do
    Logger.info("[Worker] begin_handoff: #{name}")
    {:noreply, name}
  end

  def handle_cast({:swarm, :resolve_conflict}, name) do
    Logger.info("[Worker] resolve_conflict: #{name}")
    {:noreply, name}
  end

  def handle_info({:swarm, :die}, name) do
    Logger.info("[Worker] swarm stopping worker: #{name}")
    {:stop, :normal, name}
  end
end
