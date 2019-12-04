defmodule StuartClientElixirTest.AuthenticatorTest do
  use ExUnit.Case

  import Mock

  alias StuartClientElixir.{Authenticator, Environment, Credentials}

  setup do
    on_exit(fn ->
      Cachex.clear(:stuart_oauth_tokens)
    end)
  end

  setup_with_mocks([
    {
      OAuth2.Client,
      [],
      [
        new: fn oauth_params ->
          sample_client(oauth_params)
        end,
        put_serializer: fn oauth_client, content_type, serializer ->
          client_with_serializer(oauth_client, content_type, serializer)
        end,
        get_token: fn oauth_client ->
          get_token_response(oauth_client)
        end
      ]
    }
  ]) do
    :ok
  end

  describe "access_token" do
    test "returns an error for bad credentials" do
      assert Authenticator.access_token(Environment.sandbox(), bad_credentials()) ==
               {:error,
                %OAuth2.Response{
                  headers: [],
                  body: %{
                    "error" => "invalid_client",
                    "error_description" =>
                      "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method."
                  },
                  status_code: 401
                }}
    end

    test "returns an error for OAuth2.Error" do
      assert Authenticator.access_token(Environment.sandbox(), error_credentials()) ==
               {:error,
                %OAuth2.Error{
                  reason:
                    {:options,
                     {:socket_options,
                      [packet_size: 0, packet: 0, header: 0, active: false, mode: :binary]}}
                }}
    end

    test "returns a new access token when no access token exists" do
      # when
      {:ok, access_token} = Authenticator.access_token(Environment.sandbox(), good_credentials())

      # then
      assert access_token == "sample-new-token"
    end

    test "returns the current valid access token when a valid access token already exists" do
      # given
      Cachex.put(
        :stuart_oauth_tokens,
        "client-id",
        sample_token(
          access_token: "sample-cached-token",
          expires_at: System.system_time(:second) + 60 * 60
        )
      )

      # when
      {:ok, access_token} = Authenticator.access_token(Environment.sandbox(), good_credentials())

      # then
      assert access_token == "sample-cached-token"
    end

    test "returns a new access token when a non valid access token already exists" do
      # given
      Cachex.put(
        :stuart_oauth_tokens,
        "client-id",
        sample_token(
          access_token: "sample-cached-token",
          expires_at: System.system_time(:second) - 60 * 60
        )
      )

      # when
      {:ok, access_token} = Authenticator.access_token(Environment.sandbox(), good_credentials())

      # then
      assert access_token == "sample-new-token"
    end
  end

  describe "forget_token!" do
    test "deletes the cached token for the given client_id" do
      Cachex.put(
        :stuart_oauth_tokens,
        "client-id",
        sample_token(
          access_token: "sample-cached-token",
          expires_at: System.system_time(:second) + 60 * 60
        )
      )

      assert {:ok, "sample-cached-token"} ==
               Authenticator.access_token(Environment.sandbox(), good_credentials())

      assert {:ok, true} == Authenticator.forget_token!("client-id")

      assert {:ok, "sample-new-token"} ==
               Authenticator.access_token(Environment.sandbox(), good_credentials())
    end
  end

  #####################
  # Private functions #
  #####################

  defp good_credentials do
    %Credentials{client_id: "client-id", client_secret: "client-secret"}
  end

  defp bad_credentials do
    %Credentials{client_id: "client-id", client_secret: "bad"}
  end

  defp error_credentials do
    %Credentials{client_id: "client-id", client_secret: "error"}
  end

  defp sample_client(
         strategy: OAuth2.Strategy.ClientCredentials,
         client_id: client_id,
         client_secret: client_secret,
         site: site
       ) do
    %OAuth2.Client{
      authorize_url: "/oauth/authorize",
      client_id: client_id,
      client_secret: client_secret,
      headers: [],
      params: %{},
      redirect_uri: "",
      ref: nil,
      request_opts: [],
      site: site,
      strategy: OAuth2.Strategy.ClientCredentials,
      token_method: :post,
      token_url: "/oauth/token"
    }
  end

  defp client_with_serializer(oauth_client, content_type, serializer) do
    %{oauth_client | serializers: %{content_type => serializer}}
  end

  defp get_token_response(%OAuth2.Client{client_secret: "client-secret"}) do
    {:ok,
     sample_client_with_token(
       access_token: "sample-new-token",
       expires_at: System.system_time(:second) + 60 * 60
     )}
  end

  defp get_token_response(%OAuth2.Client{client_secret: "bad"}) do
    {:error,
     %OAuth2.Response{
       body: %{
         "error" => "invalid_client",
         "error_description" =>
           "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method."
       },
       headers: [],
       status_code: 401
     }}
  end

  defp get_token_response(%OAuth2.Client{client_secret: "error"}) do
    {:error,
     %OAuth2.Error{
       reason:
         {:options,
          {:socket_options, [packet_size: 0, packet: 0, header: 0, active: false, mode: :binary]}}
     }}
  end

  defp sample_token(access_token: access_token, expires_at: expires_at) do
    %OAuth2.AccessToken{
      access_token: access_token,
      expires_at: expires_at,
      other_params: %{"created_at" => 1_533_049_354, "scope" => "api"},
      refresh_token: nil,
      token_type: "Bearer"
    }
  end

  defp sample_client_with_token(access_token: access_token, expires_at: expires_at) do
    %OAuth2.Client{
      authorize_url: "/oauth/authorize",
      client_id: good_credentials().client_id,
      client_secret: good_credentials().client_secret,
      headers: [],
      params: %{},
      redirect_uri: "",
      ref: nil,
      request_opts: [],
      token: sample_token(access_token: access_token, expires_at: expires_at),
      site: "https://sandbox-api.stuart.com",
      strategy: OAuth2.Strategy.ClientCredentials,
      token_method: :post,
      token_url: "/oauth/token"
    }
  end
end
