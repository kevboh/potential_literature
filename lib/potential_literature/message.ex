defmodule PotentialLiterature.Message do
  alias PotentialLiterature.Schema.{Guild, Message, User}
  alias PotentialLiterature.Repo

  def record(msg) do
    datetime =
      msg.timestamp
      |> DateTime.shift_zone!("America/New_York", Tz.TimeZoneDatabase)

    guild = get_or_insert_guild(msg.guild_id)
    user = get_or_insert_user(msg.author)

    %Message{}
    |> Message.changeset(%{
      id: Nostrum.Snowflake.dump(msg.id),
      channel_id: Nostrum.Snowflake.dump(msg.channel_id),
      user_id: user.id,
      guild_id: guild.id,
      content: msg.content,
      timestamp: DateTime.to_naive(datetime),
      year_julian_day: PotentialLiterature.JulianDay.to_julian_day(datetime),
      is_violation: is_violation?(msg),
      is_bypass: String.starts_with?(msg.content, "!")
    })
    |> Repo.insert()
  end

  @url_regex ~r/http?s:\/\/[-a-zA-Z0-9\._~:\/\?#\[\]@!\$&\'\(\)\*\+\,;%=]+/

  defp is_violation?(msg) do
    c =
      msg.content
      |> String.downcase()
      |> String.normalize(:nfd)
      |> String.replace(@url_regex, "")
      |> String.codepoints()

    "e" in c
  end

  defp get_or_insert_user(%Nostrum.Struct.User{
         id: sid,
         username: username,
         discriminator: discriminator
       }) do
    id = Nostrum.Snowflake.dump(sid)

    Repo.get(User, id) ||
      Repo.insert!(%User{id: id, username: username, discriminator: discriminator})
  end

  defp get_or_insert_guild(sid) do
    id = Nostrum.Snowflake.dump(sid)
    Repo.get(Guild, id) || Repo.insert!(%Guild{id: id})
  end
end
