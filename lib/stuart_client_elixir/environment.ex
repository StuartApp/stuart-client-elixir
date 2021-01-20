defmodule StuartClientElixir.Environment do
  @enforce_keys [:base_url]
  defstruct @enforce_keys

  def sandbox, do: %__MODULE__{base_url: "https://api.sandbox.stuart.com"}
  def production, do: %__MODULE__{base_url: "https://api.stuart.com"}
end
