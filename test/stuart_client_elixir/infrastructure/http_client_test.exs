defmodule StuartClientElixirTest.Infrastructure.HttpClientTest do
  use ExUnit.Case

  import Mock
  alias StuartClientElixir.Infrastructure.{Authenticator, HttpClient, Environment, Credentials}

  setup_with_mocks([
    {
      Authenticator,
      [],
      [
        access_token: fn _environment, _credentials -> "sample-access-token" end
      ]
    },
    {
      HTTPoison,
      [],
      [
        get: fn _, _ ->
          {:ok, %HTTPoison.Response{status_code: 201, body: Jason.encode!(%{sample: "response"})}}
        end,
        post: fn _, _, _ ->
          {:ok, %HTTPoison.Response{status_code: 201, body: Jason.encode!(%{sample: "response"})}}
        end
      ]
    }
  ]) do
    :ok
  end

  describe "get" do
    test "calls HTTPoison with correct parameters" do
      # OAuth2.Client.new(
      #  strategy: OAuth2.Strategy.ClientCredentials,
      #  client_id: "sample-client-id",
      #  client_secret: "sample-client-id",
      #  site: Environment.sandbox().base_url
      # )

      # given
      HttpClient.get("/sample-endpoint", %{
        environment: Environment.sandbox(),
        credentials: sample_credentials()
      })

      # then
      assert called(
               HTTPoison.get(
                 "https://sandbox-api.stuart.com/sample-endpoint",
                 expected_headers()
               )
             )
    end
  end

  describe "post" do
    test "calls HTTPoison with correct parameters" do
      # when
      HttpClient.post("/sample-endpoint", sample_request_body(), config())

      # then
      assert called(
               HTTPoison.post(
                 "https://sandbox-api.stuart.com/sample-endpoint",
                 sample_request_body(),
                 expected_headers()
               )
             )
    end
  end

  #####################
  # Private functions #
  #####################

  defp sample_credentials do
    %Credentials{
      client_id: "sample-client-id",
      client_secret: "sample-client-secret"
    }
  end

  defp sample_request_body, do: Jason.encode!(%{sample: "request"})

  defp expected_headers,
    do: [
      Authorization: "Bearer sample-access-token",
      "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}",
      "Content-Type": "application/json"
    ]

  defp config,
    do: %{
      environment: Environment.sandbox(),
      credentials: sample_credentials()
    }
end
