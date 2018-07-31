defmodule StuartClientElixir.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [worker(Cachex, [:stuart_oauth_tokens, []])]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
