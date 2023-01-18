defmodule PotentialLiterature.Repo.Migrations.CountViolationGlyphs do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :glyph_count, :integer
    end
  end
end
