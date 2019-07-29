[ ![Codeship Status for StuartApp/stuart-client-elixir](https://app.codeship.com/projects/832b17c0-77a6-0136-8b5b-3e7b2f9f0830/status?branch=master)](https://app.codeship.com/projects/300202)

# Stuart Elixir Client

For a complete documentation of all endpoints offered by the Stuart API, you can read the [Stuart API documentation](https://stuart.api-docs.io).

## Install

```elixir
# mix.exs

def deps do
  [
    {:stuart_client_elixir, "~> 1.2.0"}
  ]
end
```

## Usage

#### Custom requests

#### Send a GET request to the Stuart API

```elixir
alias StuartClientElixir.{Environment, Credentials}

credentials = %Credentials{client_id: "...", client_secret: "..."}

StuartClientElixir.get(
  "/v2/jobs/95896", %{environment: Environment.sandbox(), credentials: credentials})
```

#### Send a POST request to the Stuart API

```elixir
alias StuartClientElixir.{Environment, Credentials}

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

credentials = %Credentials{client_id: "...", client_secret: "..."}
StuartClientElixir.post("/v2/jobs", Jason.encode!(job), %{environment: Environment.sandbox(), credentials: credentials})
```
