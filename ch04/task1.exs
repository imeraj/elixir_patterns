{time, _result} =
  :timer.tc(fn ->
    1..10
    |> Enum.map(fn _ ->
      Task.async(fn ->
        Process.sleep(1500)
      end)
    end)
    |> Task.await_many()
  end)

System.convert_time_unit(time, :microsecond, :millisecond)

task =
  Task.async(fn ->
    Process.sleep(1000)
    :all_good
  end)

Task.yield(task, 500)

Task.yield(task, 1000)

Task.async(fn -> Process.sleep(1000) end) |> Task.await(500)
