defmodule PotentialLiterature.Message do
  alias PotentialLiterature.Schema.{Guild, Message, User}
  alias PotentialLiterature.Repo

  def record(msg) do
    datetime =
      msg.timestamp
      |> DateTime.shift_zone!("America/New_York", Tz.TimeZoneDatabase)

    guild = get_or_insert_guild(msg.guild_id)
    user = get_or_insert_user(msg.author)

    count = violation_count(msg)

    %Message{}
    |> Message.changeset(%{
      id: Nostrum.Snowflake.dump(msg.id),
      channel_id: Nostrum.Snowflake.dump(msg.channel_id),
      user_id: user.id,
      guild_id: guild.id,
      content: msg.content,
      timestamp: DateTime.to_naive(datetime),
      year_julian_day: PotentialLiterature.JulianDay.to_julian_day(datetime),
      is_violation: count > 0,
      is_bypass: String.starts_with?(msg.content, "!"),
      glyph_count: count
    })
    |> Repo.insert()
  end

  @url_regex ~r/http?s:\/\/[-a-zA-Z0-9\._~:\/\?#\[\]@!\$&\'\(\)\*\+\,;%=]+/
  @emoji_regex ~r/<a?:\S+:\d+>/

  defp violation_count(msg) do
    msg.content
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(@url_regex, "")
    |> String.replace(@emoji_regex, "")
    |> String.codepoints()
    |> Enum.filter(&is_violating_glyph/1)
    |> length()
  end

  def snowball(words), do: is_snowball(nil, words)
  defp is_snowball(nil, [word | rest]), do: is_snowball(String.length(word), rest)
  defp is_snowball(prev_len, [word | rest]) do
    curr_length = String.length(word)
    if curr_length - prev_len == 1 do
      is_snowball(curr_length, rest)
    else
      is_snowball(false, [])
    end
  end
  defp is_snowball(false, []), do: false
  defp is_snowball(prev_len, []), do: true

  defp is_violating_glyph(c), do: c in ["e", "℮", "ℯ", "ⅇ"]

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
