defmodule CarAuction.Cache do
  @moduledoc false
  use GenServer

  alias CarAuction.CacheRestore

  require Logger

  @ets_table_name __MODULE__.ETS

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def put(auction_id, params) do
    GenServer.cast(__MODULE__, {:put, auction_id, params})
  end

  def get(auction_id) do
    case :ets.lookup(@ets_table_name, auction_id) do
      [{^auction_id, params}] -> {:ok, params}
      [] -> {:error, :not_found}
    end
  end

  @impl GenServer
  def init(_opts) do
    cache_status = case CacheRestore.transfer_ets_table() do
      :no_backup ->
        :ets.new(@ets_table_name,
          [
            :set,
            :protected,
            :named_table,
            {:read_concurrency, true},
            {:heir, Process.whereis(CacheRestore), nil}
          ]
        )
        :cache_up

      :restoring ->
        :cache_down
    end

    {:ok, cache_status}
  end

  @impl GenServer
  def handle_cast({:put, id, params}, :cache_up) do
    :ets.insert(@ets_table_name, {id, params})
    {:noreply, :cache_up}
  end

  def handle_cast({:put, _id, _params}, state) do
    Logger.warning("Failed to insert into cache as the cache is down")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:"ETS-TRANSFER", _table, _from, _data}, _state) do
    Logger.info("Cache was successfully restored")
    {:noreply, :cache_up}
  end
end
