defmodule PotentialLiterature.Schema.User do
  use Ecto.Schema

  alias PotentialLiterature.Schema.Message

  @primary_key {:id, :string, []}
  schema "users" do
    field(:username, :string)
    field(:discriminator, :string)

    timestamps()

    has_many(:messages, Message)
  end
end
