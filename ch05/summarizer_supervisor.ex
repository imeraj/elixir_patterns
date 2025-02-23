defmodule SummarizerSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl Supervisor
  def init(init_args) do
    partitions = Keyword.fetch!(init_args, :partitions)

    children = [
      {PartitionSupervisor,
       child_spec: EventCollector.child_spec(init_args),
       name: EventCollectorPartitionSupervisor,
       partitions: partitions},
      {PartitionSupervisor,
       child_spec: EventFlusher.child_spec(init_args),
       name: EventFlusherPartitionSupervisor,
       partitions: partitions,
       with_arguments: fn [opts], partition ->
         [Keyword.put(opts, :partition, partition)]
       end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

{:ok, pid} = SummarizerSupervisor.start_link(flush_interval: 1000, partitions: 3)
Supervisor.which_children(pid)

test_users = [
  %User{id: "1", name: "MegaCorp", plan: :enterprise},
  %User{id: "2", name: "Gundam", plan: :basic},
  %User{id: "3", name: "CoffeeCentral", plan: :free},
  %User{id: "4", name: "CodeTogether", plan: :enterprise},
  %User{id: "5", name: "FPFunHouse", plan: :basic},
  %User{id: "6", name: "FPFunHouse", plan: :basic},
  %User{id: "7", name: "FPFunHouse", plan: :basic},
  %User{id: "8", name: "FPFunHouse", plan: :basic},
  %User{id: "9", name: "FPFunHouse", plan: :basic},
  %User{id: "10", name: "FPFunHouse", plan: :basic}
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

Supervisor.stop(pid)
