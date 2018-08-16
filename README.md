# Stuart Elixir Client

For a complete documentation of all endpoints offered by the Stuart API, you can visit [Stuart API documentation](https://stuart.api-docs.io).

## Install

```elixir
# mix.exs

def application do
  [applications: [:stuart_client_elixir]]
end

def deps do
  [
    {:stuart_client_elixir, "~> 1.1.0"}
  ]
end
```

## Usage

#### Custom requests

#### Send a GET request to the Stuart API

```elixir
alias StuartClientElixir.Infrastructure.{HttpClient, Environment}

config = %{environment: Environment.sandbox(), client_id: "c6058849d0a056fc743203acb...103485c3edc51b16a9260cc7a7688", client_secret: "aa6a415fce31967501662c1960f...cff99acb19dbc1aae6f76c9c619"}

HttpClient.perform_get "/v2/jobs/95896", config
```

#### Send a POST request to the Stuart API

```elixir
alias StuartClientElixir.Infrastructure.{HttpClient, Environment}

job = %{
  job: %{
    transport_type: "bike",
    pickups: [
      %{
        address: "46 Boulevard Barbès, 75018 Paris",
        comment: "Wait outside for an employee to come.",
        contact: %{
          firstname: "Martin",
          lastname: "Pont",
          phone: "+33698348756",
          company: "KFC Paris Barbès"
        }
      }
    ],
    dropoffs: [
      %{
        address: "156 rue de Charonne, 75011 Paris",
        package_description: "Red packet.",
        comment: "code: 3492B. 3e étage droite. Sonner à Durand.",
        contact: %{
          firstname: "Alex",
          lastname: "Durand",
          phone: "+33634981209",
          company: "Durand associates."
        }
      }
    ]
  }
}
config = %{environment: Environment.sandbox(), client_id: "c6058849d0a056fc743203acb8e6a8...85c3edc51b16a9260cc7a7688", client_secret: "aa6a415fce31967501662c1960fcbfb...9acb19dbc1aae6f76c9c619"}

HttpClient.perform_post "/v2/jobs", Jason.encode!(job), config

