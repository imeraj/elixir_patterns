existing_user_index = 1
new_user_index = 2

my_counter = :counters.new(2, [:write_concurrency])

1..100_000
|> Task.async_stream(
  fn _ ->
    user_type = Enum.random([:existing_user, :new_user])

    case user_type do
      :existing_user ->
        :counters.add(my_counter, existing_user_index, 1)

      :new_user ->
        :counters.add(my_counter, new_user_index, 1)
    end
  end,
  max_concurrency: 500
)
|> Stream.run()

:counters.get(my_counter, existing_user_index)

:counters.get(my_counter, new_user_index)
