defmodule ExoticCarSaleTrackerSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_) do
    children = [
      ExoticCarLookup,
      ExoticCarSaleTracker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

mock_sales_list = [
  {2000, "Honda", "Accord", 22_000},
  {2019, "Acura", "Integra", 32_000},
  {2022, "Pagani", "Zonda", 4_181_000},
  {2023, "Lamborghini", "Huracan", 324_000},
  {2022, "Ferrari", "488", 450_000},
  {2018, "Mazda", "MX-5", 29_000},
  {2015, "Chevy", "Camaro", 65_000},
  {2023, "Lamborghini", "Huracan", 349_500},
  {2015, "Chevy", "Camaro", 62_000},
  {2022, "Ferrari", "488", 492_600}
]

{:ok, pid} = ExoticCarSaleTrackerSupervisor.start_link([])

Enum.each(mock_sales_list, fn {year, make, model, price} ->
  ExoticCarSaleTracker.track_sale(year, make, model, price)
end)

ExoticCarSaleTracker.get_avg_price_stats()

Supervisor.stop(pid)
