defmodule MyApp.MonitoringTools.ReductionWatcher do
  use GenServer

  require Logger

  @interval 10_000
  @top_n 5

  # Client API
  def start_link(opts) do
    if start_server?(),
      do: GenServer.start_link(__MODULE__, opts, name: __MODULE__),
      else: :ignore
  end

  # Server callbacks
  @impl GenServer
  def init(_opts) do
    {:ok, nil, {:continue, :schedule_next_run}}
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, state) do
    Process.send_after(self(), :log_top_n, @interval)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:log_top_n, state) do
    memory_hogs =
      Process.list()
      |> Enum.map(fn pid ->
        {:total_heap_size, measurement} = Process.info(pid, :total_heap_size)
        {pid, measurement}
      end)
      |> Enum.sort_by(fn {_, total_heap_size} -> total_heap_size end, :desc)
      |> Enum.take(@top_n)

    Logger.info("Top memory processes: #{inspect(memory_hogs)}")

    {:noreply, state, {:continue, :schedule_next_run}}
  end

  defp start_server?() do
    :my_app
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:enabled, false)
  end
end
