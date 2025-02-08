unique_ets_table = :ets.new(:my_table, [:set])

user_1 = {1, %{first_name: "Alex", last_name: "Koutmos", favourite_lang: :elixir}}
user_2 = {2, %{first_name: "Hugo", last_name: "Barauna", favourite_lang: :elixir}}
user_3 = {3, %{first_name: "Joe", last_name: "Smith", favourite_lang: :go}}

:ets.insert(unique_ets_table, user_1)
:ets.insert(unique_ets_table, user_2)
:ets.insert(unique_ets_table, user_3)

:ets.lookup(unique_ets_table, 1)
:ets.lookup(unique_ets_table, 2)

:ets.lookup(unique_ets_table, 100)

unique_ets_table
|> :ets.select([
  {
    {:"$1", %{first_name: :"$2", last_name: :"$3", favourite_lang: :elixir}},
    [],
    [{{:"$1", :"$2", :"$3"}}]
  }
])

unique_ets_table
|> :ets.select_count([
  {
    {:"$1", %{favourite_lang: :"$2"}},
    [{:==, :"$2", :elixir}],
    [true]
  }
])

unique_ets_table
|> :ets.select([
  {
    {:"$1", %{first_name: :"$2", last_name: :"$3", favourite_lang: :elixir}},
    [],
    [%{id: :"$1", first_name: :"$2", last_name: :"$3"}]
  }
])

select_fn =
  :ets.fun2ms(fn {id, %{first_name: first_name, last_name: last_name, favourite_lang: :elixir}} ->
    {id, first_name, last_name}
  end)

:ets.select(unique_ets_table, select_fn)

count_fn = :ets.fun2ms(fn {_, %{favourite_lang: :elixir}} -> true end)

:ets.select(unique_ets_table, count_fn) |> length()

:ets.delete(unique_ets_table)
