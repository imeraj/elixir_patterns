defmodule SimpleGenServer do
  @moduledoc false
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def child_spec(init_arg) do
    %{
      id: init_arg,
      start: {__MODULE__, :start_link, [init_arg]}
    }
  end

  @impl GenServer
  def init(name) do
    Process.flag(:trap_exit, true)
    IO.puts("Starting GenServer: #{inspect(name)}")

    {:ok, name}
  end

  @impl GenServer
  def terminate(_reason, name) do
    IO.puts("Terminating GenServer: #{inspect(name)}")
    :ok
  end
end
