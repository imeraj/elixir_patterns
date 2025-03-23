defmodule CarAuction.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      CarAuction.CacheRestore,
      CarAuction.Cache,
      CarAuction.Registry,
      CarAuction.DynamicSupervisor,
      CarAuction.Init
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

CarAuction.Supervisor.start_link([])
CarAuction.Auction.place_bid("1", 1, 10000)
CarAuction.Auction.place_bid("1", 2, 12000)
CarAuction.Cache.get("1")

Process.whereis(CarAuction.Cache)
CarAuction.Cache |> Process.whereis() |> GenServer.stop(:brutal)

CarAuction.Cache.get("1")
Process.whereis(CarAuction.Cache)

# Stress testing
total_requests = 10_000
{exec_time, _results} = :timer.tc(fn ->
  1..total_requests
  |> Enum.map(fn num ->
  Task.async(fn ->
     CarAuction.Auction.place_bid("3", "user_2", 350_000 + num)
     end)
  end)
  |> Task.await_many()
  end, :millisecond)

reqs_per_second = 1_000 / exec_time * total_requests

total_requests = 10_000
{exec_time, _results} = :timer.tc(fn ->
  1..total_requests
  |> Enum.map(fn _num ->
    Task.async(fn ->
      CarAuction.Cache.get("3")
      :ok
      end)
    end)
  |> Task.await_many()
end, :millisecond)

reqs_per_second = 1_000 / exec_time * total_requests
