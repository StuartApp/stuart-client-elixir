defmodule StuartClientElixir.Infrastructure.Credentials do
  @enforce_keys [:client_id, :client_secret]
  defstruct @enforce_keys
end
