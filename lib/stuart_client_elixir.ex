defmodule StuartClientElixir do
  alias StuartClientElixir.{HttpClient, Authenticator}

  defdelegate get(resource, options), to: HttpClient
  defdelegate post(resource, body, options), to: HttpClient
  defdelegate patch(resource, body, options), to: HttpClient
  defdelegate forget_token!(client_id), to: Authenticator
end
