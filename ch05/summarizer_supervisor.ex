defmodule SummarizerSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_init_args) do
    children = [
      {EventCollector, []},
      {EventFlusher, [flush_interval: 1_000]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

{:ok, pid} = SummarizerSupervisor.start_link([])
Supervisor.which_children(pid)

test_users = [
  %User{id: "1", name: "MegaCorp", plan: :enterprise},
  %User{id: "2", name: "Gundam", plan: :basic},
  %User{id: "3", name: "CoffeeCentral", plan: :free},
  %User{id: "4", name: "CodeTogether", plan: :enterprise},
  %User{id: "5", name: "FPFunHouse", plan: :basic}
]

1..100_000
|> Task.async_stream(
  fn _ ->
    user = Enum.random(test_users)
    EventCollector.record_event(user)
  end,
  max_concurrency: 2000
)
|> Stream.run()
