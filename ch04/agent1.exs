{:ok, agent_pid} = Agent.start(fn -> [] end)

Process.alive?(agent_pid)

Agent.get(agent_pid, & &1)

Enum.each(1..10, fn value -> Agent.update(agent_pid, &[value | &1]) end)

Agent.get(agent_pid, & &1)

Agent.stop(agent_pid)

Process.alive?(agent_pid)
