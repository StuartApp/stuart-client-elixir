defmodule StuartClientElixirTest.Infrastructure.EnvironmentTest do
  use ExUnit.Case

  alias StuartClientElixir.Infrastructure.Environment

  test "sandbox" do
    assert Environment.sandbox() == %Environment{base_url: "https://sandbox-api.stuart.com"}
  end

  test "production" do
    assert Environment.production() == %Environment{base_url: "https://api.stuart.com"}
  end
end
