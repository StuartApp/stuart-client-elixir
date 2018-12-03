defmodule StuartClientElixir.Authenticator do
  alias StuartClientElixir.{Environment, Credentials}

  @typep access_token :: binary()
  @typep environment :: map()
  @typep credentials :: map()
  @typep ok_response :: {:ok, access_token()}
  @typep error_response :: {:error, map()}

  @callback access_token(environment(), credentials()) :: ok_response | error_response

  def access_token(%Environment{} = environment, %Credentials{} = credentials) do
    if has_valid_token?(credentials) do
      access_token_from_cache!(credentials)
    else
      new_access_token(environment, credentials)
    end
  end

  def forget_token!(client_id) do
    remove_from_cache(client_id)
  end

  #####################
  # Private functions #
  #####################

  defp new_access_token(%Environment{base_url: base_url}, %Credentials{} = credentials) do
    with oauth_client <- oauth_client(base_url, credentials),
         {:ok, %OAuth2.Client{client_id: client_id, token: token}} <-
           OAuth2.Client.get_token(oauth_client),
         {:ok, %OAuth2.AccessToken{access_token: access_token}} <- add_to_cache(client_id, token) do
      {:ok, access_token}
    else
      {:error, %OAuth2.Response{} = oauth_response} -> {:error, oauth_response}
    end
  end

  defp has_valid_token?(%Credentials{} = credentials) do
    cache_exists?(credentials) && !OAuth2.AccessToken.expired?(token_from_cache(credentials))
  end

  def oauth_client(site, %Credentials{client_id: client_id, client_secret: client_secret}) do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.ClientCredentials,
      client_id: client_id,
      client_secret: client_secret,
      site: site
    )
  end

  defp cache_exists?(%Credentials{client_id: client_id}),
    do: {:ok, true} == Cachex.exists?(:stuart_oauth_tokens, client_id)

  defp access_token_from_cache!(%Credentials{} = credentials),
    do: {:ok, token_from_cache(credentials).access_token}

  defp token_from_cache(%Credentials{client_id: client_id}) do
    case Cachex.get(:stuart_oauth_tokens, client_id) do
      {:ok, nil} -> nil
      {:ok, %OAuth2.AccessToken{} = token} -> token
    end
  end

  defp add_to_cache(client_id, %OAuth2.AccessToken{} = oauth2_token) do
    {:ok, true} = Cachex.put(:stuart_oauth_tokens, client_id, oauth2_token)

    {:ok, oauth2_token}
  end

  defp remove_from_cache(client_id) do
    {:ok, _} = Cachex.del(:stuart_oauth_tokens, client_id)
  end
end
