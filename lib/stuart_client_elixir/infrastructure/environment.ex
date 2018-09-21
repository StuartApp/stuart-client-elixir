defmodule StuartClientElixir.Infrastructure.Environment do
  @enforce_keys [:base_url]
  defstruct @enforce_keys

  def sandbox, do: %__MODULE__{base_url: "https://sandbox-api.stuart.com"}
  def production, do: %__MODULE__{base_url: "https://api.stuart.com"}
end
