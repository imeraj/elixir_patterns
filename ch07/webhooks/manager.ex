defmodule Webhooks.Manager do
  use GenServer
  require Logger

  @max_attempts 5

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def publish_webhook(url, payload) do
    GenServer.cast(__MODULE__, {:publish_webhook, url, payload})
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:publish_webhook, url, payload}, state) do
    webhook_config = %{
      attempts: 1,
      url: url,
      payload: payload
    }

    task_ref = send_webhook(webhook_config)
    updated_state = Map.put(state, task_ref, webhook_config)

    {:noreply, updated_state}
  end

  @impl GenServer
  def handle_info({task_ref, response}, state) do
    Process.demonitor(task_ref, [:flush])

    updated_state = case response do
      :ok -> handle_success(task_ref, state)
      :error -> handle_error(task_ref, state)
    end

    {:noreply, updated_state}
  end

  def handle_info({:DOWN, task_ref, :process, _pid, _reason}, state) do
    updated_state = handle_error(task_ref, state)

    {:noreply, updated_state}
  end

  defp handle_success(task_ref, state) do
    case Map.fetch(state, task_ref) do
      {:ok, webhook_config} ->
        Logger.info("Webhook sent successfully to #{webhook_config.url}")
        Map.delete(state, task_ref)

        _ -> Logger.error("Webhook not found for task ref #{task_ref}")
        state
    end
  end

  defp handle_error(task_ref, state) do
    case Map.fetch(state, task_ref) do
      {:ok, %{attempts: attempts} = webhook_config} when attempts <= @max_attempts ->
        Logger.warning("Webhook failed to send to #{webhook_config.url}. Retrying...")
        updated_webhook_config = Map.update!(webhook_config, :attempts, &(&1 + 1))
        new_task_ref = send_webhook(webhook_config)
        Map.put(state, new_task_ref, updated_webhook_config)

      {:ok, %{url: url, attempts: attempts}} ->
        Logger.error("Webhook failed to send to #{url} after #{attempts} attempts")
        Map.delete(state, task_ref)

      _ ->
         Logger.error("Webhook not found for task ref #{task_ref}")
         state
    end
  end

  defp send_webhook(webhook_config) do
    %Task{ref: ref} =
      Task.Supervisor.async_nolink(
        task_supervisor_via(webhook_config),
        fn ->
          webhook_config.attempts
          |> webhook_attempt_sleep()
          |> Process.sleep()

          Webhooks.Publisher.send(webhook_config.url, webhook_config.payload)
        end
      )
    ref
  end

  defp task_supervisor_via(webhook_config) do
    {:via, PartitionSupervisor, {Webhooks.TaskSupervisors, webhook_config}}
  end

  defp webhook_attempt_sleep(1), do: 0
  defp webhook_attempt_sleep(2), do: 1_000
  defp webhook_attempt_sleep(3), do: 5_000
  defp webhook_attempt_sleep(4), do: 10_000
  defp webhook_attempt_sleep(5), do: 30_000
end
