defmodule Hive.Worker do
  use GenServer
  require Logger

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

  def handle_call({:swarm, :begin_handoff}, _from, name) do
    Logger.info("begin_handoff: #{name}")
    {:reply, :resume, name}
  end

  def handle_cast({:swarm, :end_handoff}, name) do
    Logger.info("begin_handoff: #{name}")
    {:noreply, name}
  end

  def handle_cast({:swarm, :resolve_conflict, _delay}, name) do
    {:noreply, name}
  end

  def handle_info({:swarm, :die}, name) do
    Logger.info("killing worker on #{inspect(node)}: #{name}")
    {:stop, :normal, name}
  end
end
