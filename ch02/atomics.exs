existing_user_index = 1
new_user_index = 2

my_atomic = :atomics.new(2, signed: false)

1..100_000
|> Task.async_stream(
  fn _ ->
    user_type = Enum.random([:existing_user, :new_user])

    case user_type do
      :existing_user ->
        :atomics.add(my_atomic, existing_user_index, 1)

      :new_user ->
        :atomics.add(my_atomic, new_user_index, 1)
    end
  end,
  max_concurrency: 500
)
|> Stream.run()

:atomics.get(my_atomic, existing_user_index)

:atomics.get(my_atomic, new_user_index)
