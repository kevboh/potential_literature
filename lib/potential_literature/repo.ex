defmodule PotentialLiterature.Repo do
  use Ecto.Repo,
    otp_app: :potential_literature,
    adapter: Ecto.Adapters.SQLite3
end
