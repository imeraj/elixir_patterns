defmodule Webhooks.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    partitions = Keyword.get(opts, :partitions, System.schedulers_online())

    children = [
      {PartitionSupervisor, child_spec: Task.Supervisor, name: Webhooks.TaskSupervisors, partitions: partitions},
      Webhooks.Manager
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

Webhooks.Supervisor.start_link(partitions: 4)

webhooks = [
  {"https://customer-1.app/webhooks", %{order_id: "1", status: "SHIPPED"}},
  {"https://customer-2.app/webhooks", %{order_id: "2", status: "SHIPPED"}},
  {"https://customer-3.app/webhooks", %{order_id: "3", status: "SHIPPED"}},
  {"https://customer-4.app/webhooks", %{order_id: "4", status: "SHIPPED"}},
  {"https://customer-5.app/webhooks", %{order_id: "5", status: "SHIPPED"}},
  {"https://customer-6.app/webhooks", %{order_id: "6", status: "SHIPPED"}},
  {"https://customer-7.app/webhooks", %{order_id: "7", status: "SHIPPED"}},
  {"https://customer-8.app/webhooks", %{order_id: "8", status: "SHIPPED"}}
]

Enum.each(webhooks, fn {url, payload} ->
  Webhooks.Manager.publish_webhook(url, payload)
end)
