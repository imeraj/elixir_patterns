ExUnit.start()

defmodule MyApp.QueueTest do
  @moduledoc """
  Copy the module in `iex`
  Copy test file in `iex`

  ExUnit.run()
  """
  use ExUnit.Case

  describe "MyApp.Queue" do
    setup %{module: module, test: test} do
      queue_name = Module.concat([module, test, Queue])

      child_spec = %{
        id: MyApp.Queue,
        restart: :transient,
        start: {MyApp.Queue, :start_link, [[], queue_name]}
      }

      queue_pid = start_supervised!(child_spec)

      %{queue_name: queue_name, queue_pid: queue_pid}
    end

    test "should return first element in the queue", %{queue_name: queue_name} do
      MyApp.Queue.push(queue_name, 1)
      MyApp.Queue.push(queue_name, 2)

      value = MyApp.Queue.pop(queue_name)

      assert(value == 1)
    end
  end
end
