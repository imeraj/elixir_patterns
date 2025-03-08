defmodule RateLimiter.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      RateLimiter.Registry,
      RateLimiter.DynamicSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

rate_limiters = [
 stripe: [requests_per_second: 60],
 shopify: [requests_per_second: 30],
 twilio: [requests_per_second: 120],
 slow_api: [requests_per_second: 1]
]

{:ok, pid} = RateLimiter.Supervisor.start_link([])

Enum.each(rate_limiters, fn {id, opts} ->
 RateLimiter.DynamicSupervisor.spawn_rate_limiter(id, opts)
end)

Enum.map([:stripe, :shopify, :twilio, :slow_api], fn rate_limiter ->
  {:ok, pid} = RateLimiter.Registry.lookup(rate_limiter)
  pid
end)

Enum.each(1..10, fn num ->
 IO.puts("Request #{num}")

 Task.async(fn ->
   RateLimiter.LeakyBucket.wait_for_turn(:slow_api)
   time = Time.truncate(Time.utc_now(), :second)
   IO.puts("[#{time}] Serviced request #{num}")
 end)
end)

Enum.each(1..10, fn num ->
 IO.puts("Request #{num}")

 Task.async(fn ->
   RateLimiter.LeakyBucket.wait_for_turn(:stripe)
   time = Time.truncate(Time.utc_now(), :second)
   IO.puts("[#{time}] Serviced request #{num}")
 end)
end)
