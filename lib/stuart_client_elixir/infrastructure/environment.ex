defmodule StuartClientElixir.Infrastructure.Environment do
  def sandbox, do: %{base_url: "https://sandbox-api.stuart.com"}
  def production, do: %{base_url: "https://api.stuart.com"}
end
