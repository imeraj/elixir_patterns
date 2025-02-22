defmodule EventFlusher do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Server callbacks
  @impl GenServer
  def init(opts) do
    flush_interval = Keyword.fetch!(opts, :flush_interval)

    {:ok, flush_interval, {:continue, :schedule_next_flush}}
  end

  @impl GenServer
  def handle_continue(:schedule_next_flush, flush_interval) do
    Process.send_after(self(), :flush_events, flush_interval)
    {:noreply, flush_interval}
  end

  @impl GenServer
  def handle_info(:flush_events, flush_interval) do
    write_data_to_db = EventCollector.flush_events()

    if map_size(write_data_to_db) > 0 do
      Logger.info(write_data_to_db)
    end

    {:noreply, flush_interval, {:continue, :schedule_next_flush}}
  end
end
