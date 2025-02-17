defmodule ChildSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_init_arg) do
    IO.puts("Starting Supervisor: #{inspect(__MODULE__)}")

    children = [
      {SimpleGenServer, :gen_server_two},
      {SimpleGenServer, :gen_server_three}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
