defmodule PotentialLiterature.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias PotentialLiterature.MessageConsumer
  alias PotentialLiterature.HealthCheck

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: PotentialLiterature.Worker.start_link(arg)
      # {PotentialLiterature.Worker, arg}
      MessageConsumer,
      # for fly health checks
      {Plug.Cowboy, scheme: :http, plug: HealthCheck, options: [port: 8080]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PotentialLiterature.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
