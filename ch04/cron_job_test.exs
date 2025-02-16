ExUnit.start()

defmodule MyApp.CronJobTest do
  @moduledoc """
  Copy the module in `iex`
  Copy test file in `iex`

  ExUnit.run()
  """
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  test "receives top 3 memory hogs" do
    interval_ms = 500

    fun = fn ->
      _pid = start_supervised!({MyApp.CronJob, interval_ms})
      Process.sleep(interval_ms * 2)
      GenServer.stop(MyApp.CronJob)
    end

    assert capture_log(fun) =~ "Top 3 memory hogs: "
  end
end
