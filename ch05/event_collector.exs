defmodule EventCollector do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def record_event(%User{} = user) do
    GenServer.cast(__MODULE__, {:record_event, user})
  end

  def flush_events do
    GenServer.call(__MODULE__, :flush_events)
  end

  # Server callbacks
  @impl GenServer
  def init(_) do
    {:ok, %{count: 0, data: %{}}}
  end

  @impl GenServer
  def handle_cast({:record_event, user}, %{count: count, data: data}) do
    data = Map.update(data, user.id, 1, &(&1 + 1))
    {:noreply, %{count: count + 1, data: data}}
  end

  @impl GenServer
  def handle_call(:flush_events, _from, %{count: count, data: data}) do
    if count > 0 do
      Logger.info("{__MODULE__} - #{count} events flushed")
    end

    {:reply, data, %{count: 0, data: %{}}}
  end
end
