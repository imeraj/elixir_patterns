defmodule RateLimiter.LeakyBucket do
  @moduledoc false
  use GenServer

  def start_link(name, opts) do
    GenServer.start_link(__MODULE__, opts, name: {:via, Registry, {RateLimiter.Registry, name}})
  end

  def wait_for_turn(name) do
    GenServer.call({:via, Registry, {RateLimiter.Registry, name}}, :wait_for_turn, :infinity)
  end

  @impl GenServer
  def init(opts) do
    requests_per_second = Keyword.fetch!(opts, :requests_per_second)
    request_pop_in_ms = floor(:timer.seconds(1) / requests_per_second)

    state = %{
      request_queue: :queue.new(),
      queue_length: 0,
      requests_per_second: requests_per_second,
      request_pop_in_ms: request_pop_in_ms
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:wait_for_turn, from, %{request_queue: request_queue, queue_length: original_queue_length} = state) do
    updated_request_queue = :queue.in(from, request_queue)

    updated_state =
      state
      |> Map.put(:request_queue, updated_request_queue)
      |> Map.put(:queue_length, original_queue_length + 1)

    if original_queue_length == 0 do
      {:noreply, updated_state, {:continue, :schedule_next_run}}
    else
      {:noreply, updated_state}
    end
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, state) do
    Process.send_after(self(), :pop_request, state.request_pop_in_ms)
    {:noreply, state}
  end

  @impl Genserver
  def handle_info(:pop_request, %{queue_length: 0} = state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:pop_request, %{request_queue: request_queue, queue_length: original_queue_length} = state) do
    {{:value, requesting_process}, updated_request_queue} = :queue.out(request_queue)
    GenServer.reply(requesting_process, :ok)

    updated_state =
      state
      |> Map.put(:request_queue, updated_request_queue)
      |> Map.put(:queue_length, original_queue_length - 1)

    {:noreply, updated_state, {:continue, :schedule_next_run}}
  end
end
