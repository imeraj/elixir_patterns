defmodule CarAuction.Registry do
  @moduledoc false

  def child_spec(opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end

  def lookup_auction(auction_id) do
    case Registry.lookup(__MODULE__, auction_id) do
      [{^auction_id, auction_pid}] -> {:ok, auction_pid}
      [] -> {:error, :not_found}
    end
  end
end
