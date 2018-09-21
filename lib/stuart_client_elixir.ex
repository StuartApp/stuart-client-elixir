defmodule StuartClientElixir do
  alias StuartClientElixir.HttpClient

  defdelegate get(resource, options), to: HttpClient
  defdelegate post(resource, body, options), to: HttpClient
end
