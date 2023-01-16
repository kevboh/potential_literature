defmodule PotentialLiterature.Repo.Migrations.AddInitialTables do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :string, primary_key: true

      add :user_id, :string

      add :channel_id, :string
      add :guild_id, :string

      add :content, :string
      add :timestamp, :naive_datetime

      add :year_julian_day, :integer
      add :is_violation, :boolean
      add :is_bypass, :boolean
    end

    # faster querying for all messages on a given day in a given guild
    create index(:messages, [:year_julian_day, :guild_id])

    create table(:guilds, primary_key: false) do
      add :id, :string, primary_key: true

      timestamps()
    end

    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :username, :string
      add :discriminator, :string

      timestamps()
    end

    create table(:awards) do
      add :user_id, :string
      add :guild_id, :string
      add :year_julian_day, :integer
      add :trophy, :string

      timestamps()
    end

    create index(:awards, [:year_julian_day, :user_id, :guild_id])
  end
end
