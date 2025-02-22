defmodule User do
  @moduledoc false

  @enforce_keys [:id, :name, :plan]
  defstruct [:id, :name, :plan]
end
