defmodule StuartClientElixirTest.EnvironmentTest do
  use ExUnit.Case

  alias StuartClientElixir.Environment

  test "sandbox" do
    assert Environment.sandbox() == %Environment{base_url: "https://sandbox-api.stuart.com"}
  end

  test "production" do
    assert Environment.production() == %Environment{base_url: "https://api.stuart.com"}
  end
end
