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

  @oauth_error %Credentials{
    client_id: "oauth-error",
    client_secret: "oauth-error"
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
        get: fn url, _headers, _options -> response(:get, url) end,
        post: fn url, _body, _headers, _options -> response(:post, url) end,
        patch: fn url, _body, _headers, _options -> response(:patch, url) end
      ]
    }
  ]) do
    :ok
  end

  describe "get" do
    test "calls HTTPoison with correct parameters" do
      expected_response = %{body: %{"sample" => "get response"}, status_code: 200}

      assert HttpClient.get("/sample-endpoint", config()) == expected_response

      assert called(
               HTTPoison.get(
                 "https://api.sandbox.stuart.com/sample-endpoint",
                 expected_headers(),
                 expected_options()
               )
             )
    end

    test "returns explicit error when authentication fails because of bad credentials" do
      expected_response = %{body: %{"error" => "Bad credentials"}, status_code: 401}

      assert HttpClient.get("/sample-endpoint", config(@bad_credentials)) == expected_response
    end

    test "returns explicit error when authentication fails because of other OAuth error" do
      expected_response = {:error, oauth2_error()}

      assert HttpClient.get("/sample-endpoint", config(@oauth_error)) == expected_response
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
                 "https://api.sandbox.stuart.com/sample-endpoint",
                 sample_request_body(),
                 expected_headers(),
                 expected_options()
               )
             )
    end

    test "returns explicit error when authentication fails because of bad credentials" do
      expected_response = %{body: %{"error" => "Bad credentials"}, status_code: 401}

      assert HttpClient.post("/sample-endpoint", sample_request_body(), config(@bad_credentials)) ==
               expected_response
    end

    test "returns explicit error when authentication fails because of other OAuth error" do
      expected_response = {:error, oauth2_error()}

      assert HttpClient.post("/sample-endpoint", sample_request_body(), config(@oauth_error)) ==
               expected_response
    end

    test "returns explicit error when POST request fails" do
      expected_response = {:error, %HTTPoison.Error{id: nil, reason: :timeout}}

      assert HttpClient.post("/timeout", sample_request_body(), config()) == expected_response
    end
  end

  describe "patch" do
    test "calls HTTPoison with correct parameters" do
      expected_response = %{body: %{"sample" => "patch response"}, status_code: 200}

      assert HttpClient.patch("/sample-endpoint", sample_request_body(), config()) ==
               expected_response

      assert called(
               HTTPoison.patch(
                 "https://api.sandbox.stuart.com/sample-endpoint",
                 sample_request_body(),
                 expected_headers(),
                 expected_options()
               )
             )
    end

    test "returns explicit error when authentication fails because of bad credentials" do
      expected_response = %{body: %{"error" => "Bad credentials"}, status_code: 401}

      assert HttpClient.patch("/sample-endpoint", sample_request_body(), config(@bad_credentials)) ==
               expected_response
    end

    test "returns explicit error when authentication fails because of other OAuth error" do
      expected_response = {:error, oauth2_error()}

      assert HttpClient.patch("/sample-endpoint", sample_request_body(), config(@oauth_error)) ==
               expected_response
    end

    test "returns explicit error when PATCH request fails" do
      expected_response = {:error, %HTTPoison.Error{id: nil, reason: :timeout}}

      assert HttpClient.patch("/timeout", sample_request_body(), config()) == expected_response
    end
  end

  describe "handles 204 no content response" do
    @expected_no_content_response %{status_code: 204, body: ""}

    test "204 no content in GET" do
      assert HttpClient.get("/no_content", config()) == @expected_no_content_response
    end

    test "204 no content in POST" do
      assert HttpClient.post("/no_content", sample_request_body(), config()) ==
               @expected_no_content_response
    end

    test "204 no content in PATCH" do
      assert HttpClient.patch("/no_content", sample_request_body(), config()) ==
               @expected_no_content_response
    end
  end

  describe "handles invalid json response" do
    @expected_invalid_json_response {:error,
                                     %Jason.DecodeError{data: "", position: 0, token: nil}}

    test "invalid json in GET" do
      assert HttpClient.get("/invalid_json", config()) == @expected_invalid_json_response
    end

    test "invalid json in POST" do
      assert HttpClient.post("/invalid_json", sample_request_body(), config()) ==
               @expected_invalid_json_response
    end

    test "invalid json in PATCH" do
      assert HttpClient.patch("/invalid_json", sample_request_body(), config()) ==
               @expected_invalid_json_response
    end
  end

  #####################
  # Private functions #
  #####################

  @timeout_url "https://api.sandbox.stuart.com/timeout"
  @no_content_url "https://api.sandbox.stuart.com/no_content"
  @invalid_json_url "https://api.sandbox.stuart.com/invalid_json"

  defp response(_, @timeout_url) do
    {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
  end

  defp response(_, @no_content_url) do
    {:ok, %HTTPoison.Response{status_code: 204, body: ""}}
  end

  defp response(_, @invalid_json_url) do
    {:ok, %HTTPoison.Response{status_code: 500, body: ""}}
  end

  defp response(:get, _) do
    {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(%{sample: "get response"})}}
  end

  defp response(:post, _) do
    {:ok, %HTTPoison.Response{status_code: 201, body: Jason.encode!(%{sample: "post response"})}}
  end

  defp response(:patch, _) do
    {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(%{sample: "patch response"})}}
  end

  defp authenticator_response(@good_credentials) do
    {:ok, "sample-access-token"}
  end

  defp authenticator_response(@bad_credentials) do
    {:error, %OAuth2.Response{status_code: 401, body: %{"error" => "Bad credentials"}}}
  end

  defp authenticator_response(@oauth_error) do
    {:error, oauth2_error()}
  end

  defp oauth2_error do
    %OAuth2.Error{
      reason:
        {:options,
         {:socket_options, [packet_size: 0, packet: 0, header: 0, active: false, mode: :binary]}}
    }
  end

  defp sample_request_body, do: Jason.encode!(%{sample: "request"})

  defp expected_headers,
    do: [
      Authorization: "Bearer sample-access-token",
      "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}",
      "Content-Type": "application/json"
    ]

  defp expected_options,
    do: [recv_timeout: 10_000]

  defp config(credentials \\ @good_credentials),
    do: %{
      environment: Environment.sandbox(),
      credentials: credentials
    }
end
