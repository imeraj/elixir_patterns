defmodule SimpleGenServer do
  @moduledoc false
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def child_spec(name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [name]}
    }
  end

  @impl GenServer
  def init(state) do
    IO.puts("Starting GenServer: #{state}")

    {:ok, state}
  end
end
