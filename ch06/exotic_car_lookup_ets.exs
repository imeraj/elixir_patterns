defmodule ExoticCarLookup do
  @moduledoc false
  use GenServer

  @ets_table_name __MODULE__.ETS

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def exotic_car?(year, make, model) do
    case :ets.lookup(@ets_table_name, {year, make}) do
      [{year_make, models}] ->
        MapSet.member?(models, model)

      _ ->
        false
    end
  end

  @impl GenServer
  def init(_) do
    :ets.new(@ets_table_name, [:set, :protected, :named_table, {:read_concurrency, true}])
    hydrate_ets()

    # this is important to keep the process running
    {:ok, nil}
  end

  defp hydrate_ets do
    exotic_car_dets_file =
      __DIR__
      |> Path.join("exotic_car_filter.dets")
      |> String.to_charlist()

    {:ok, dets_instance} =
      :dets.open_file(
        :exotic_car_dets_backup,
        file: exotic_car_dets_file,
        type: :set,
        access: :read
      )

    :dets.to_ets(dets_instance, @ets_table_name)

    :ok = :dets.close(dets_instance)
  end
end
