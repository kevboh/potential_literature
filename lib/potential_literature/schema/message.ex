defmodule PotentialLiterature.Schema.Message do
  use Ecto.Schema

  import Ecto.Changeset

  alias PotentialLiterature.Schema.Guild
  alias PotentialLiterature.Schema.User

  @primary_key {:id, :string, []}
  schema "messages" do
    field(:channel_id, :string)
    field(:content, :string)
    field(:timestamp, :naive_datetime)
    field(:year_julian_day, :integer)
    field(:is_violation, :boolean)
    field(:is_bypass, :boolean)

    belongs_to(:user, User)
    belongs_to(:guild, Guild)
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [
      :id,
      :channel_id,
      :user_id,
      :guild_id,
      :content,
      :timestamp,
      :year_julian_day,
      :is_violation,
      :is_bypass
    ])
    |> validate_required([
      :id,
      :channel_id,
      :user_id,
      :guild_id,
      :content,
      :timestamp,
      :year_julian_day,
      :is_violation,
      :is_bypass
    ])
  end
end
