defmodule MyApp.MonitoringTools.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    if start_supervisor?(),
      do: Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__),
      else: :ignore
  end

  @impl Supervisor
  def init(_) do
    children = [
      MyApp.MonitoringTools.MemoryWatcher,
      MyApp.MonitoringTools.ReductionWatcher
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp start_supervisor? do
    :my_app
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:enabled, false)
  end
end
