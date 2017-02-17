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
    if rem(:rand.uniform(10), 2) == 0 do
      case :pg2.get_local_members(Hive.pg2_group()) do
        [pid | _] when is_pid(pid) ->
          Logger.info("Chaos: killing #{inspect(pid)}")
          GenServer.stop(pid, {:error, :rand_kill})
        _ -> nil
      end
    end

    Process.send_after(self(), :random_kill, @kill_delay)
    {:noreply, state}
  end

  defp random_worker, do: Hive.random_worker()
end
