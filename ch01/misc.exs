my_data = %{name: "John Smith", age: 42, favorite_lang: :elixir}

base64_serialized = my_data |> :erlang.term_to_binary() |> Base.encode64()

base64_serialized |> Base.decode64!() |> :erlang.binary_to_term([:safe])

"test string" |> :erlang.md5()

1..100_000
|> Enum.reduce(%{}, fn number, acc ->
  index = :erlang.phash2("Some data - #{number}", 10)
  Map.update(acc, index, 1, &(&1 + 1))
end)

:erlang.memory()

:erlang.system_info(:system_version)
:erlang.system_info(:atom_count)
:erlang.system_info(:atom_limit)
:erlang.system_info(:ets_count)
:erlang.system_info(:schedulers)
:erlang.system_info(:emu_flavor)
