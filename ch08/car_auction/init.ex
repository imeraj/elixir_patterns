defmodule CarAuction.Init do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    start_auction_processes()

    :ignore
  end

  defp start_auction_processes do
    [
      %{
        "bid_leading_user_id" => "",
        "bid_price" => 8000,
        "description" => "Reliably get from point A to B.",
        "id" => "1",
        "make" => "Honda",
        "mileage" => "72500",
        "model" => "Accord",
        "transmission" => "Manual",
        "year" => "2008"
      },
      %{
        "bid_leading_user_id" => "",
        "bid_price" => 250000,
        "description" => "Naturally aspirated V10 goodness.",
        "id" => "2",
        "make" => "Lamborghini",
        "mileage" => "12000",
        "model" => "Huracan Performante",
        "transmission" => "Automatic",
        "year" => "2018"
      },
      %{
        "bid_leading_user_id" => "",
        "bid_price" => 350000,
        "description" => "The pinnacle of Italian performance.",
        "id" => "3",
        "make" => "Ferrari",
        "mileage" => "6000",
        "model" => "F8 Tributo",
        "transmission" => "Automatic",
        "year" => "2020"
      }
    ]
    |> Enum.each(fn %{"id" => id} = params ->
      CarAuction.DynamicSupervisor.spawn_auction(id, params)
    end)
  end
end
