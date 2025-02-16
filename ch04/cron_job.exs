defmodule MyApp.CronJob do
  use GenServer, restart: :transient

  require Logger

  # Client API
  def start_link(run_interval_ms) do
    GenServer.start_link(__MODULE__, run_interval_ms, name: __MODULE__)
  end

  # Server callbacks
  @impl GenServer
  def init(run_interval) do
    {:ok, run_interval, {:continue, :schedule_next_run}}
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, run_interval) do
    Process.send_after(self(), :perform_cron_work, run_interval)
    {:noreply, run_interval}
  end

  @impl GenServer
  def handle_info(:perform_cron_work, run_interval) do
    memory_hogs =
      Process.list()
      |> Enum.map(fn pid ->
        {:memory, memory} = Process.info(pid, :memory)
        {pid, memory}
      end)
      |> Enum.sort_by(fn {_, memory} -> -memory end, :desc)
      |> Enum.take(3)

    Logger.info("Top 3 memory hogs: #{inspect(memory_hogs)}")

    {:noreply, run_interval, {:continue, :schedule_next_run}}
  end
end

MyApp.CronJob.start_link(10_000)

GenServer.stop(MyApp.CronJob)
