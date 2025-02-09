data = [
  %{name: "Ferrari Italia", type: :sports_car},
  %{name: "Honda Passport", type: :crossover},
  %{name: "Chevy Camaro", type: :sports_car},
  %{name: "Dodge Ram", type: :truck}
]

Enum.filter(data, fn
  %{type: :sports_car} -> true
  _ -> false
end)

Enum.reject(data, &match?(%{type: :sports_car}, &1))

Enum.filter(data, fn
  %{type: type} when type in [:crossoever, :truck] -> true
  _ -> false
end)

Enum.uniq([1, 2, 3, 4, 5])
Enum.uniq([1, 1, 2, 2, 3, 3, 3.0])

Enum.uniq([
  %{id: 1, name: "Alex"},
  %{id: 1, name: "Alexander"},
  %{id: 2, name: "Joe"},
  %{id: 3, name: "Jane"}
])

Enum.uniq(["Hello", "BEAM", "BEAM", "World"])

data = [
  %{id: 1, name: "Alex"},
  %{id: 1, name: "Alexander"},
  %{id: 2, name: "Joe"},
  %{id: 3, name: "Jane"}
]

Enum.uniq_by(data, & &1.id)

vehicle_inventory = [
  %{year: 1967, make: "Chevy", model: "Camaro"},
  %{year: 2020, make: "Lamborghini", model: "Huracan"},
  %{year: 1994, make: "Honda", model: "Civic"},
  %{year: 2000, make: "Honda", model: "Accord"},
  %{year: 2004, make: "Mitsubishi", model: "Evolution 8"},
  %{make: "Toyota", model: "Supra"},
  %{make: "Toyota", model: "MR2"},
  %{make: "Mazda", model: "RX-7"}
]

vehicle_inventory
|> Enum.map(fn
  %{year: year, make: make, model: model}
  when not is_nil(year) and not is_nil(make) and not is_nil(model) ->
    "#{year} #{make} #{model}"

  _ ->
    :invalid_data
end)
|> Enum.reject(&(&1 == :invalid_data))

Enum.group_by(vehicle_inventory, & &1.make)
Enum.split_with(vehicle_inventory, &Map.has_key?(&1, :year))

vehicle_inventory
|> Enum.sort_by(fn
  %{year: year} -> year
  _ -> nil
end)
|> Enum.with_index()
|> Enum.map(fn
  {%{year: year, make: make, model: model}, index} ->
    "#{index}. #{year} #{make} #{model}"

  {%{make: make, model: model}, index} ->
    "#{index}. #{make} #{model}"
end)

vehicle_inventory
|> Enum.reduce(MapSet.new(), fn %{make: make}, acc ->
  MapSet.put(acc, make)
end)
|> MapSet.to_list()

vehicle_inventory
|> Enum.reduce_while(MapSet.new(), fn
  %{year: year}, acc ->
    {:cont, MapSet.put(acc, year)}

  _, _ ->
    {:halt, {:error, :missing_year}}
end)

Enum.map(vehicle_inventory, & &1.make) |> Enum.frequencies()

Enum.map(vehicle_inventory, & &1.make) |> Enum.frequencies_by(&String.downcase(&1))
