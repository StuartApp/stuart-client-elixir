defmodule StuartClientElixirTest.HttpClientTest do
  use ExUnit.Case

  import Mock
  alias StuartClientElixir.{Authenticator, HttpClient, Environment, Credentials}

  @good_credentials %Credentials{
    client_id: "good-id",
    client_secret: "good-secret"
  }

  @bad_credentials %Credentials{
    client_id: "bad-id",
    client_secret: "bad-secret"
  }

  setup_with_mocks([
    {
      Authenticator,
      [],
      [
        access_token: fn _environment, credentials -> authenticator_response(credentials) end
      ]
    },
    {
      HTTPoison,
      [],
      [
        get: fn url, _ -> response(:get, url) end,
        post: fn url, _, _ -> response(:post, url) end
      ]
    }
  ]) do
    :ok
  end

  describe "get" do
    test "calls HTTPoison with correct parameters" do
      expected_response = %{body: %{"sample" => "get response"}, status_code: 201}

      assert HttpClient.get("/sample-endpoint", config()) == expected_response

      assert called(
               HTTPoison.get(
                 "https://sandbox-api.stuart.com/sample-endpoint",
                 expected_headers()
               )
             )
    end

    test "returns explicit error when authentication fails" do
      expected_response = %{body: %{"error" => "Bad credentials"}, status_code: 401}

      assert HttpClient.get("/sample-endpoint", config(@bad_credentials)) == expected_response
    end

    test "returns explicit error when GET request fails" do
      expected_response = {:error, %HTTPoison.Error{id: nil, reason: :timeout}}

      assert HttpClient.get("/timeout", config()) == expected_response
    end
  end

  describe "post" do
    test "calls HTTPoison with correct parameters" do
      expected_response = %{body: %{"sample" => "post response"}, status_code: 201}

      assert HttpClient.post("/sample-endpoint", sample_request_body(), config()) ==
               expected_response

      assert called(
               HTTPoison.post(
                 "https://sandbox-api.stuart.com/sample-endpoint",
                 sample_request_body(),
                 expected_headers()
               )
             )
    end

    test "returns explicit error when authentication fails" do
      expected_response = %{body: %{"error" => "Bad credentials"}, status_code: 401}

      assert HttpClient.post("/sample-endpoint", sample_request_body(), config(@bad_credentials)) ==
               expected_response
    end

    test "returns explicit error when POST request fails" do
      expected_response = {:error, %HTTPoison.Error{id: nil, reason: :timeout}}

      assert HttpClient.post("/timeout", sample_request_body(), config()) == expected_response
    end
  end

  #####################
  # Private functions #
  #####################

  defp response(:get, "https://sandbox-api.stuart.com/timeout") do
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  defp response(:get, _) do
    {:ok, %HTTPoison.Response{status_code: 201, body: Jason.encode!(%{sample: "get response"})}}
  end

  defp response(:post, "https://sandbox-api.stuart.com/timeout") do
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  defp response(:post, _) do
    {:ok, %HTTPoison.Response{status_code: 201, body: Jason.encode!(%{sample: "post response"})}}
  end

  defp authenticator_response(@good_credentials) do
    {:ok, "sample-access-token"}
  end

  defp authenticator_response(@bad_credentials) do
    {:error, %OAuth2.Response{status_code: 401, body: %{"error" => "Bad credentials"}}}
  end

  defp sample_request_body, do: Jason.encode!(%{sample: "request"})

  defp expected_headers,
    do: [
      Authorization: "Bearer sample-access-token",
      "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}",
      "Content-Type": "application/json"
    ]

  defp config(credentials \\ @good_credentials),
    do: %{
      environment: Environment.sandbox(),
      credentials: credentials
    }
end
