defmodule PotentialLiterature.Schema.Award do
  use Ecto.Schema

  import Ecto.Changeset

  alias PotentialLiterature.Schema.{Guild, User}

  schema "awards" do
    field(:trophy, :string)
    field(:year_julian_day, :integer)

    timestamps()

    belongs_to(:user, User)
    belongs_to(:guild, Guild)
  end

  def changeset(award, params \\ %{}) do
    award
    |> cast(params, [:trophy, :year_julian_day, :user_id, :guild_id])
    |> validate_required([:trophy, :year_julian_day, :user_id, :guild_id])
  end
end
