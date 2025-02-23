defmodule EventCollector do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def record_event(%User{} = user) do
    user.id
    |> via_tuple()
    |> GenServer.cast({:record_event, user})
  end

  def flush_events(partition) do
    partition
    |> via_tuple()
    |> GenServer.call(:flush_events)
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
      Logger.info("{__MODULE__}:#{inspect(self)} - #{count} events flushed")
    end

    {:reply, data, %{count: 0, data: %{}}}
  end

  defp via_tuple(term) do
    {:via, PartitionSupervisor, {EventCollectorPartitionSupervisor, term}}
  end
end
