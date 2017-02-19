defmodule Hive.Chaos do
  use GenServer
  require Logger

  @start_delay Application.fetch_env!(:hive, :start_delay)
  @kill_delay Application.fetch_env!(:hive, :kill_delay)

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Process.send_after(self(), :random_start, @start_delay)
    Process.send_after(self(), :random_kill, @kill_delay)
    {:ok, :ok}
  end

  def handle_info(:random_start, state) do
    Hive.Registry.register(random_worker())
    Process.send_after(self(), :random_start, @start_delay)
    {:noreply, state}
  end

  def handle_info(:random_kill, state) do
    case :pg2.get_local_members(Hive.pg2_group()) do
      [pid | _] when is_pid(pid) -> stop_server(pid)
      _ -> nil
    end

    Process.send_after(self(), :random_kill, @kill_delay)
    {:noreply, state}
  end

  defp random_worker, do: Hive.random_worker()

  defp stop_server(pid) do
    {m, f, reason} = case :rand.uniform(5) do
      1 -> {GenServer, :stop, {:error, :rand_kill}}
      2 -> {GenServer, :stop, :normal}
      3 -> {GenServer, :stop, :shutdown}
      4 -> {Hive.Worker, :raise, "Triggered by Hive.Chaos"}
      5 -> {Process, :exit, {:error, :rand_kill}}
    end
    name = Hive.Worker.get_name(pid)
    Logger.error("[Chaos] stopping #{name} with: #{m}.#{f}(#{inspect(pid)}, #{inspect(reason)})")
    apply(m, f, [pid, reason])
  end
end
