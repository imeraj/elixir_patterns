defmodule RateLimiter.Registry do
  @moduledoc false

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end

  def lookup(rate_limiter_id) do
    case Registry.lookup(__MODULE__, rate_limiter_id) do
      [{rate_limiter_pid, _rate_limiter_key}] -> {:ok, rate_limiter_pid}
      [] -> {:error, :not_found}
    end
  end
end
