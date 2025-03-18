defmodule Webhooks.Publisher do
  require Logger

  def send(url, payload) do
    Logger.info("Sending webhook to #{url} with payload #{inspect(payload)}")

    Process.sleep(500)

    case Enum.random(1..10) do
      1 -> raise "An error occurred while sending the webhook"
      2 -> :error
      3 -> :bad_match = Enum.random([1,2,3,4,5])
      _ -> :ok
    end
  end
end
