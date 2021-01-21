defmodule StuartClientElixir.HttpClient do
  alias StuartClientElixir.{Environment, Authenticator}

  @typep url :: binary()
  @typep body :: map()
  @typep options :: map()
  @typep ok_response :: {:ok, map()}
  @typep error_response :: {:error, binary() | map()}

  @callback get(url, options) :: ok_response | error_response
  @callback post(url, body, options) :: ok_response | error_response
  @callback patch(url, body, options) :: ok_response | error_response

  def get(resource, options) do
    perform_request(:get, options, resource)
  end

  def post(resource, body, options) do
    perform_request(:post, options, resource, body)
  end

  def patch(resource, body, options) do
    perform_request(:patch, options, resource, body)
  end

  #####################
  # Private functions #
  #####################

  def perform_request(
        method,
        %{
          environment: environment,
          credentials: credentials
        },
        resource,
        body \\ nil
      )
      when method in [:get, :post, :patch] do
    with url <- url(resource, environment),
         {:ok, access_token} <- Authenticator.access_token(environment, credentials),
         headers <- default_headers(access_token) do
      case method do
        :get -> HTTPoison.get(url, headers, default_options())
        :post -> HTTPoison.post(url, body, headers, default_options())
        :patch -> HTTPoison.patch(url, body, headers, default_options())
      end
      |> to_api_response()
    else
      {:error, %OAuth2.Response{}} = oauth_response -> to_api_response(oauth_response)
      {:error, %OAuth2.Error{}} = oauth_error -> to_api_response(oauth_error)
    end
  end

  defp default_options do
    [recv_timeout: 10_000]
  end

  defp url(resource, %Environment{base_url: base_url}), do: "#{base_url}#{resource}"

  defp default_headers(access_token) do
    [
      Authorization: "Bearer #{access_token}",
      "User-Agent": "stuart-client-elixir/#{Application.spec(:stuart_client_elixir, :vsn)}",
      "Content-Type": "application/json"
    ]
  end

  defp to_api_response({:ok, %HTTPoison.Response{status_code: 204}}) do
    %{status_code: 204, body: ""}
  end

  defp to_api_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    with {:ok, decoded_body} <- Jason.decode(body) do
      %{status_code: status_code, body: decoded_body}
    end
  end

  defp to_api_response({:error, %OAuth2.Response{status_code: status_code, body: body}}) do
    %{status_code: status_code, body: body}
  end

  defp to_api_response({:error, error}) do
    {:error, error}
  end
end
