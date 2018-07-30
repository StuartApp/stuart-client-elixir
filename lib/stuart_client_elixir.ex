defmodule StuartClientElixir do
  @moduledoc """
  Documentation for StuartClientElixir.
  """

  @doc """
  Hello world.

  ## Examples

      iex> StuartClientElixir.hello()
      :world

  """
  def hello do
    :world
  end

  defmodule Infrastructure do
    defmodule Environment do
      def sandbox, do: %{base_url: "https://sandbox-api.stuart.com"}
      def production, do: %{base_url: "https://api.stuart.com"}
    end

    defmodule HttpClient do
      def perform_get(environment, client_id, client_secret, resource) do
        HTTPoison.get!(
          "#{environment.base_url}#{resource}",
          default_headers(access_token: access_token(environment, client_id, client_secret))
        )
        |> to_api_response
      end

      defp access_token(environment, client_id, client_secret) do
        StuartClientElixir.Infrastructure.Authenticator.access_token(
          environment,
          client_id,
          client_secret
        )
      end

      defp default_headers(access_token: access_token) do
        [
          Authorization: "Bearer #{access_token}",
          "User-Agent": "stuart-client-elixir/#{Mix.Project.config()[:version]}"
        ]
      end

      defp to_api_response(%HTTPoison.Response{status_code: status_code, body: body}) do
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
