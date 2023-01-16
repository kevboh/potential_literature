defmodule PotentialLiterature.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PotentialLiterature.MessageConsumer,
      PotentialLiterature.Repo,
      PotentialLiterature.Scheduler,
      # for fly health checks
      {Plug.Cowboy, scheme: :http, plug: PotentialLiterature.HealthCheck, options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: PotentialLiterature.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
