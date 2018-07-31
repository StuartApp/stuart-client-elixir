defmodule StuartClientElixir.Infrastructure.Authenticator do
  def access_token(environment, client_id, client_secret) do
    OAuth2.Client.get_token!(oauth_client(environment.base_url, client_id, client_secret)).token.access_token
  end

  defp oauth_client(site, client_id, client_secret) do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.ClientCredentials,
      client_id: client_id,
      client_secret: client_secret,
      site: site
    )
  end
end
