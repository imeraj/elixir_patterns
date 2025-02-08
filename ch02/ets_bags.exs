my_metrics_table = :ets.new(:my_table, [:bag, :public])

Task.async(fn ->
  :ets.insert(my_metrics_table, {:auth_attempt, %{user: "Alex", ts: NaiveDateTime.utc_now()}})
  :ets.insert(my_metrics_table, {:auth_attempt, %{user: "Hugo", ts: NaiveDateTime.utc_now()}})
  :ets.insert(my_metrics_table, {:new_user_created, %{user: "Jane", ts: NaiveDateTime.utc_now()}})
end)

:ets.tab2list(my_metrics_table)

:ets.delete(my_metrics_table)

my_metrics_table = :ets.new(:my_table, [:bag, :private])

Task.async(fn ->
  :ets.insert(my_metrics_table, {:auth_attempt, %{user: "Alex", ts: NaiveDateTime.utc_now()}})
  :ets.insert(my_metrics_table, {:auth_attempt, %{user: "Hugo", ts: NaiveDateTime.utc_now()}})
  :ets.insert(my_metrics_table, {:new_user_created, %{user: "Jane", ts: NaiveDateTime.utc_now()}})
end)

:ets.tab2list(my_metrics_table)

:ets.delete(my_metrics_table)
