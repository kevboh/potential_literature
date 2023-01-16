defmodule PotentialLiterature.Schema.Guild do
  use Ecto.Schema

  alias PotentialLiterature.Schema.Message

  @primary_key {:id, :string, []}
  schema "users" do
    timestamps()

    has_many(:messages, Message)
  end
end
