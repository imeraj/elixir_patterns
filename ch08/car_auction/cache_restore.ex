defmodule CarAuction.CacheRestore do
  @moduledoc false
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def transfer_ets_table do
    GenServer.call(__MODULE__, :transfer_ets_table)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call(:transfer_ets_table, {from_pid, _tag}, table) do
    if Process.whereis(CarAuction.Cache) == from_pid do
      do_transfer(table)
     else
      Logger.warning("Only a call from the CarAuction.Cache process can trigger a restore")
     {:reply, :error, table}
    end
  end

  @impl GenServer
  def handle_info({:"ETS-TRANSFER", table, _from, _data}, _state) do
    Logger.info("Backing up ETS cache from CarAuction.Cache.")

    {:noreply, table}
  end

  defp do_transfer(nil) do
    Logger.info("Attempt to restore cache failed as heir does not own ETS table.")

    {:reply, :no_backup, nil}
  end

  defp do_transfer(table) do
    Logger.info("Restoring ETS cache to CarAuction.Cache.")

    :ets.give_away(table, Process.whereis(CarAuction.Cache), nil)

    {:reply, :restoring, nil}
  end
end
