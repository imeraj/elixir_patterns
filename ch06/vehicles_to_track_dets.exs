{:ok, dets_table} =
  :dets.open_file(:vehicles_to_track,
    file: ~c"exotic_car_filter.dets",
    type: :set,
    auto_save: 10_000
  )

vehicles_to_track = %{
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
}

Enum.each(vehicles_to_track, fn {year, makes_models} ->
  Enum.each(makes_models, fn {make, models} ->
    :dets.insert(dets_table, {{year, make}, MapSet.new(models)})
  end)
end)

:dets.sync(dets_table)

:dets.close(dets_table)
