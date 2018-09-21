defmodule StuartClientElixir.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{id: Cachex, start: {Cachex, :start_link, [:stuart_oauth_tokens, []]}},
      %{id: Queue, start: {StuartClientElixir.Queue, :start_link, []}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
