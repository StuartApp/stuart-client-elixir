defmodule StuartClientElixir do
  defmodule Infrastructure do
    defmodule Environment do
      def sandbox, do: %{base_url: "https://sandbox-api.stuart.com"}
      def production, do: %{base_url: "https://api.stuart.com"}
    end

    defmodule HttpClient do
      def perform_get(resource, config) do
        HTTPoison.get(
          url(resource, config),
          default_headers(
            access_token(config.environment, config.client_id, config.client_secret)
          )
        )
        |> to_api_response
      end

      def perform_post(resource, body, config) do
        HTTPoison.post(
          url(resource, config),
          body,
          default_headers(
            access_token(config.environment, config.client_id, config.client_secret)
          )
        )
      end

      defp url(resource, config), do: "#{config.environment.base_url}#{resource}"

      defp access_token(environment, client_id, client_secret) do
        StuartClientElixir.Infrastructure.Authenticator.access_token(
          environment,
          client_id,
          client_secret
        )
      end

      defp default_headers(access_token) do
        [
          Authorization: "Bearer #{access_token}",
          "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}",
          "Content-Type": "application/json"
        ]
      end

      defp to_api_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}} ) do
        %{status_code: status_code, body: Jason.decode!(body)}
      end
    end

    defmodule Authenticator do
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
  end
end
