defmodule StuartClientElixir.Infrastructure.Authenticator do
  def access_token(environment, client_id, client_secret) do
    case has_valid_token?(client_id) do
      true -> token_from_cache(client_id).token.access_token
      false -> new_access_token(environment, client_id, client_secret).token.access_token
    end
  end

  defp new_access_token(environment, client_id, client_secret) do
    OAuth2.Client.get_token!(oauth_client(environment.base_url, client_id, client_secret))
    |> add_to_cache
  end

  defp has_valid_token?(client_id) do
    cache_exists(client_id) && !OAuth2.AccessToken.expired?(token_from_cache(client_id).token)
  end

  def oauth_client(site, client_id, client_secret) do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.ClientCredentials,
      client_id: client_id,
      client_secret: client_secret,
      site: site
    )
  end

  defp cache_exists(client_id) do
    case Cachex.exists?(:stuart_oauth_tokens, client_id) do
      {:ok, false} -> false
      _ -> true
    end
  end

  defp token_from_cache(client_id) do
    case Cachex.get(:stuart_oauth_tokens, client_id) do
      {:ok, nil} -> nil
      {:ok, token} -> token
    end
  end

  defp add_to_cache(oauth2_token) do
    Cachex.put(:stuart_oauth_tokens, oauth2_token.client_id, oauth2_token)
    oauth2_token
  end
end
