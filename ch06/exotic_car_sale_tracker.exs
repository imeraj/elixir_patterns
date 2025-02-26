defmodule ExoticCarSaleTracker do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_avg_price_stats do
    GenServer.call(__MODULE__, :get_avg_price_stats)
  end

  def track_sale(year, make, model, price) do
    GenServer.cast(__MODULE__, {:track_sale, {year, make, model, price}})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(:get_avg_price_stats, _from, state) do
    reply =
      Enum.map(state, fn {year_make_model, {count, total_price}} ->
        {year_make_model, total_price / count}
      end)
      |> Map.new()

    {:reply, reply, state}
  end

  @impl GenServer
  def handle_cast({:track_sale, {year, make, model, price}}, state) do
    vechicle = {year, make, model}

    new_state =
      if ExoticCarLookup.exotic_car?(year, make, model) do
        Map.update(state, vechicle, {1, price}, fn {count, total_price} ->
          {count + 1, total_price + price}
        end)
      else
        state
      end

    {:noreply, new_state}
  end
end
