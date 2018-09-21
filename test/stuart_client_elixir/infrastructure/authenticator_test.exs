defmodule StuartClientElixirTest.Infrastructure.AuthenticatorTest do
  use ExUnit.Case

  import Mock

  alias StuartClientElixir.Infrastructure.{Authenticator, Environment, Credentials}

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
        new: fn _ -> sample_client() end,
        get_token!: fn _ ->
          sample_client_with_token(
            access_token: "sample-new-token",
            expires_at: System.system_time(:second) + 60 * 60
          )
        end
      ]
    }
  ]) do
    :ok
  end

  describe "access_token" do
    test "returns a new access token when no access token exists" do
      # when
      access_token = Authenticator.access_token(Environment.sandbox(), sample_credentials())

      # then
      assert access_token == "sample-new-token"
    end

    test "returns the current valid access token when a valid access token already exists" do
      # given
      Cachex.put(
        :stuart_oauth_tokens,
        "client-id",
        sample_client_with_token(
          access_token: "sample-cached-token",
          expires_at: System.system_time(:second) + 60 * 60
        )
      )

      # when
      access_token = Authenticator.access_token(Environment.sandbox(), sample_credentials())

      # then
      assert access_token == "sample-cached-token"
    end

    test "returns a new access token when a non valid access token already exists" do
      # given
      Cachex.put(
        :stuart_oauth_tokens,
        "client-id",
        sample_client_with_token(
          access_token: "sample-cached-token",
          expires_at: System.system_time(:second) - 60 * 60
        )
      )

      # when
      access_token = Authenticator.access_token(Environment.sandbox(), sample_credentials())

      # then
      assert access_token == "sample-new-token"
    end
  end

  #####################
  # Private functions #
  #####################

  defp sample_credentials do
    %Credentials{client_id: "client-id", client_secret: "client-secret"}
  end

  defp sample_client do
    %OAuth2.Client{
      authorize_url: "/oauth/authorize",
      client_id: sample_credentials().client_id,
      client_secret: sample_credentials().client_secret,
      headers: [],
      params: %{},
      redirect_uri: "",
      ref: nil,
      request_opts: [],
      site: "https://sandbox-api.stuart.com",
      strategy: OAuth2.Strategy.ClientCredentials,
      token_method: :post,
      token_url: "/oauth/token"
    }
  end

  defp sample_client_with_token(access_token: access_token, expires_at: expires_at) do
    %OAuth2.Client{
      authorize_url: "/oauth/authorize",
      client_id: sample_credentials().client_id,
      client_secret: sample_credentials().client_secret,
      headers: [],
      params: %{},
      redirect_uri: "",
      ref: nil,
      request_opts: [],
      token: %OAuth2.AccessToken{
        access_token: access_token,
        expires_at: expires_at,
        other_params: %{"created_at" => 1_533_049_354, "scope" => "api"},
        refresh_token: nil,
        token_type: "Bearer"
      },
      site: "https://sandbox-api.stuart.com",
      strategy: OAuth2.Strategy.ClientCredentials,
      token_method: :post,
      token_url: "/oauth/token"
    }
  end
end
