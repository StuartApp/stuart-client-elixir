[![Codeship Status for StuartApp/stuart-client-elixir](https://app.codeship.com/projects/f9859ab0-b145-0137-da11-3e6824a8821c/status?branch=develop)](https://app.codeship.com/projects/363007)

# Stuart Elixir Client

For a complete documentation of all endpoints offered by the Stuart API, you can read the [Stuart API documentation](https://stuart.api-docs.io).

## Install

```elixir
# mix.exs

def deps do
  [
    {:stuart_client_elixir, "~> 1.2.1"}
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

#### Send a PATCH request to the Stuart API

```elixir
alias StuartClientElixir.{Environment, Credentials}

job = %{
  job: %{
    deliveries: [
      %{
        id: "43035",
        client_reference: "new_client_reference",
        package_description: "new_package_description",
        pickup: %{
          comment: "new_comment",
          contact: %{
            firstname: "new_firstname",
            lastname: "new_lastname",
            phone: "+33628046091",
            email: "sd@df.com",
            company: "new_company"
          }
        },
        dropoff: %{
          comment: "new_comment",
          contact: %{
            firstname: "new_firstname",
            lastname: "new_lastname",
            phone: "+33628046095",
            email: "new_email@mymail.com",
            company: "new_company"
          }
        }
      }
    ]
  }
}

credentials = %Credentials{client_id: "...", client_secret: "..."}
StuartClientElixir.patch("/v2/jobs/1234", Jason.encode!(job), %{environment: Environment.sandbox(), credentials: credentials})
```
