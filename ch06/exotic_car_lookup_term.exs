defmodule ExoticCarLookup do
  @moduledoc false
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def exotic_car?(year, make, model) do
    with vehicle_lookup <- :persistent_term.get(__MODULE__),
         {:ok, makes} <- Map.fetch(vehicle_lookup, year),
         {:ok, models} <- Map.fetch(makes, make) do
      model in models
    else
      _ -> false
    end
  end

  @impl GenServer
  def init(_) do
    hydrate_persistent_term()
    # this is important
    :ignore
  end

  defp hydrate_persistent_term do
    :persistent_term.put(__MODULE__, %{
      2023 => %{
        "Bugatti" => ["Chiron", "Veyron"],
        "Ferrari" => ["488", "F90"],
        "Lamborghini" => ["Aventador", "Huracan"],
        "Pagani" => ["Hyuara", "Zonda"],
        "Porsche" => ["918 Spyder", "911 GT3 RS"]
      },
      2022 => %{
        "Bugatti" => ["Chiron", "Veyron"],
        "Ferrari" => ["488", "F90"],
        "Lamborghini" => ["Aventador", "Huracan"],
        "Pagani" => ["Hyuara", "Zonda"],
        "Porsche" => ["918 Spyder", "911 GT3 RS"]
      }
    })
  end
end
