defmodule InitTelemetryTask do
  @moduledoc false
  use Task

  def start_link(metadata) do
    Task.start_link(__MODULE__, :run, [metadata])
  end

  def run(metadata) do
    IO.puts("Running Telemetry Task")

    metrics = %{system_time: System.system_time()}
    :telemetry.execute(init_event(), metrics, metadata)
  end

  def init_event do
    [:simple, :supervisor, :init]
  end

  def simple_handler(_event_name, measurements, metadata, pid) do
    IO.puts("Measurements: #{inspect(measurements)}")
    IO.puts("Metadata: #{inspect(metadata)}")
  end
end
