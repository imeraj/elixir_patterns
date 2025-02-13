defmodule MyCoolStack do
  use Agent

  def start(initial_elements \\ []) do
    Agent.start(fn -> initial_elements end, name: __MODULE__)
  end

  def stop do
    Agent.stop(__MODULE__)
  end

  def push(element) do
    Agent.update(__MODULE__, fn stack -> [element | stack] end)
  end

  def pop do
    Agent.get_and_update(__MODULE__, fn
      [] -> {{:error, "Empty Stack"}, []}
      [head | tail] -> {head, tail}
    end)
  end
end

{:ok, _stack} = MyCoolStack.start()

Process.whereis(MyCoolStack)

Enum.each(1..10, &MyCoolStack.push(&1))

MyCoolStack.pop()
MyCoolStack.pop()

MyCoolStack.stop()

MyCoolStack.start()

MyCoolStack |> Process.whereis() |> Process.info()

Enum.each(1..10, &MyCoolStack.push(&1))

:sys.get_state(MyCoolStack)
:sys.get_status(MyCoolStack)

MyCoolStack.stop()

Process.list()
|> Enum.max_by(fn pid ->
  Process.info(pid, :total_heap_size)
end)
|> Process.info()

Process.list()
|> Enum.max_by(fn pid ->
  Process.info(pid, :reductions)
end)
|> Process.info()
