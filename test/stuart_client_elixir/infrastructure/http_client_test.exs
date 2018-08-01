defmodule StuartClientElixirTest.Infrastructure.HttpClientTest do
  use ExUnit.Case
  
  import Mock
  alias StuartClientElixir.Infrastructure.{Authenticator, HttpClient, Environment}

  setup_with_mocks([
    {
      Authenticator,
      [],
      [
        access_token: fn _, _, _ -> "sample-access-token" end
      ]
    },
    {
      HTTPoison,
      [],
      [
        get: fn _, _ ->
          {:ok, %HTTPoison.Response{status_code: 201, body: Poison.encode!(%{sample: "response"})}}
        end,
        post: fn _, _, _ ->
          {:ok, %HTTPoison.Response{status_code: 201, body: Poison.encode!(%{sample: "response"})}}
        end
      ]
    }
  ]) do
    :ok
  end

  describe "perform_get" do
    test "calls HTTPoison with correct parameters" do
    OAuth2.Client.new(
				strategy: OAuth2.Strategy.ClientCredentials,
				client_id: "sample-client-id",
				client_secret: "sample-client-id",
				site: Environment.sandbox().base_url
			)
      # given
      HttpClient.perform_get("/sample-endpoint", config())

      # then
      assert called(
               HTTPoison.get(
                 "https://sandbox-api.stuart.com/sample-endpoint",
                 expected_headers()
               )
             )
    end
  end

  describe "perform_post" do
    test "calls HTTPoison with correct parameters" do
      # when
      HttpClient.perform_post("/sample-endpoint", sample_request_body(), config())

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

  defp sample_request_body, do: Poison.encode!(%{sample: "request"})

  defp expected_headers,
    do: [
      Authorization: "Bearer sample-access-token",
      "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}",
      "Content-Type": "application/json"
    ]

  defp config,
    do: %{
      environment: Environment.sandbox(),
      client_id: "c6058849d0a056fc743203acb8e6a850dad103485c3edc51b16a9260cc7a7688",
      client_secret: "aa6a415fce31967501662c1960fcbfbf4745acff99acb19dbc1aae6f76c9c619"
    }
end
