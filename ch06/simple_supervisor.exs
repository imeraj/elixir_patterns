defmodule SimpleSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    IO.puts("Starting SimpleSupervisor")

    init_task_meta = %{
      init_args: init_arg,
      pid: self()
    }

    children = [
      {SimpleGenServer, :gen_server_one},
      {SimpleGenServer, :gen_server_two},
      {SimpleGenServer, :gen_server_three},
      {InitTelemetryTask, init_task_meta}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

:telemetry.attach(
  :init_handler,
  InitTelemetryTask.init_event(),
  &InitTelemetryTask.simple_handler/4,
  self()
)

{:ok, pid} = SimpleSupervisor.start_link([])
Supervisor.which_children(pid)
Supervisor.stop(pid)
