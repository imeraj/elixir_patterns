defmodule CarAuction.Auction do
  @moduledoc false
  use GenServer

  def start_link(id, opts) do
    GenServer.start_link(__MODULE__, opts, name: {:via, Registry, {CarAuction.Registry, id}})
  end

  def place_bid(auction_id, user_id, amount) do
    GenServer.call({:via, Registry, {CarAuction.Registry, auction_id}}, {:place_bid, user_id, amount})
  end

  @impl GenServer
  def init(params) do
    {:ok, params, {:continue, :upsert_to_cache}}
  end

  @impl GenServer
  def handle_continue(:upsert_to_cache, %{"id" => id} = state) do
    CarAuction.Cache.put(id, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:place_bid, user_id, bid_amount}, _from, %{"bid_price" => current_bid_price} = state) do
    if bid_amount > current_bid_price do
      updated_state =
        state |> Map.put("bid_price", bid_amount) |> Map.put("bid_leading_user_id", user_id)

      {:reply, :bid_accepted, updated_state, {:continue, :upsert_to_cache}}
    else
      {:reply, :bid_declined, state}
    end
  end

end
