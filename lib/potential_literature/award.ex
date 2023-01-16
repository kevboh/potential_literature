defmodule PotentialLiterature.Award do
  import Ecto.Query, only: [from: 2]

  alias PotentialLiterature.Schema.{Award, Message}
  alias PotentialLiterature.{JulianDay, Repo}
  alias Nostrum.Api

  def ceremony do
    # grab the tuesday of this week
    # this is sort of a dirty trick, but…
    date = Date.beginning_of_week(Date.utc_today(), :tuesday)

    # do awards
    award_guild(date)
  end

  def award_guild(date) do
    guild_id = config_snowflake(:summary_guild_id)
    chid = config_snowflake(:summary_channel_id)
    jday = JulianDay.to_julian_day(date)

    msg = make_awards_and_message(guild_id, jday)

    Api.create_message(chid, content: msg)
  end

  defp config_snowflake(key) do
    Application.fetch_env!(:potential_literature, key)
    |> Nostrum.Snowflake.cast!()
  end

  defp make_awards_and_message(guild_id, jday) do
    ratios = generate_ratios(guild_id, jday)

    if Enum.empty?(ratios) do
      ""
    else
      awards = generate_awards(guild_id, jday)

      """
      Our Oulipo Day is at its finish. Activity (good/violations/total):
      #{format_ratios(ratios)}
      Awards:
      #{format_awards(awards)}
      """
    end
  end

  defp generate_ratios(guild_id, jday) do
    {:ok, %{rows: rows}} =
      Repo.query(
        """
          select u.id, 100.0 * cast(sum(not m.is_violation) as REAL) / count(m.user_id) as ratio, sum(not m.is_violation) good_count, count(m.user_id) message_count
          from messages m
          inner join users u on (m.user_id = u.id)
          where guild_id = $1 and year_julian_day = $2
          group by user_id
          order by ratio desc;
        """,
        [guild_id, jday]
      )

    rows
    |> Enum.map(&List.to_tuple/1)
  end

  defp format_ratios(ratios) do
    for {user_id, ratio, good_count, message_count} <- ratios, into: "" do
      "#{mention(user_id)}: #{ratio |> Decimal.from_float() |> Decimal.round(2)}% (#{good_count}g/#{message_count - good_count}v/#{message_count}t)" <>
        "\n"
    end
  end

  def generate_awards(guild_id, jday) do
    multi =
      Ecto.Multi.new()
      |> most_chatty(guild_id, jday)
      |> longest_post(guild_id, jday)
      |> most_violations(guild_id, jday)
      |> most_egregious_violation(guild_id, jday)
      |> most_bypasses(guild_id, jday)

    {:ok, _} = Repo.transaction(multi)

    multi
  end

  defp format_awards(multi) do
    for {_, {:insert, changeset, _}} <- Ecto.Multi.to_list(multi), into: "" do
      if changeset.valid? do
        ":trophy: " <> changeset.changes.trophy <> "\n"
      else
        ""
      end
    end
  end

  defp today_in_guild(guild_id, jday) do
    from(
      m in Message,
      join: u in assoc(m, :user),
      where: m.guild_id == ^guild_id and m.year_julian_day == ^jday,
      select: %{
        user_id: u.id
      },
      limit: 1
    )
  end

  defp most_chatty(multi, guild_id, jday) do
    res =
      from(m in today_in_guild(guild_id, jday),
        select_merge: %{
          message_count: fragment("count(?) as message_count", m.user_id)
        },
        where: not m.is_violation,
        group_by: m.user_id,
        order_by: fragment("message_count desc")
      )
      |> Repo.one()

    if not is_nil(res) do
      multi
      |> Ecto.Multi.insert(
        :most_chatty,
        Award.changeset(%Award{}, %{
          trophy: "#{mention(res)}: Most posts without fifth glypth (#{res.message_count})",
          year_julian_day: jday,
          user_id: res.user_id,
          guild_id: guild_id
        })
      )
    else
      multi
    end
  end

  defp longest_post(multi, guild_id, jday) do
    res =
      from(m in today_in_guild(guild_id, jday),
        select_merge: %{
          length: fragment("length(?) as length", m.content),
          content: m.content
        },
        where: not m.is_violation,
        order_by: fragment("length desc")
      )
      |> Repo.one()

    if not is_nil(res) do
      multi
      |> Ecto.Multi.insert(
        :longest_post,
        Award.changeset(%Award{}, %{
          trophy: "#{mention(res)}: Most-big good post (#{res.length}):\n#{quote_content(res)}",
          year_julian_day: jday,
          user_id: res.user_id,
          guild_id: guild_id
        })
      )
    else
      multi
    end
  end

  defp most_violations(multi, guild_id, jday) do
    res =
      from(m in today_in_guild(guild_id, jday),
        select_merge: %{
          violation_count: fragment("count(?) as violation_count", m.user_id)
        },
        where: m.is_violation and not m.is_bypass,
        group_by: m.user_id,
        order_by: fragment("violation_count desc")
      )
      |> Repo.one()

    if not is_nil(res) do
      multi
      |> Ecto.Multi.insert(
        :most_violations,
        Award.changeset(%Award{}, %{
          trophy: "#{mention(res)}: Most violations (#{res.violation_count})",
          year_julian_day: jday,
          user_id: res.user_id,
          guild_id: guild_id
        })
      )
    else
      multi
    end
  end

  defp most_egregious_violation(multi, guild_id, jday) do
    res =
      from(m in today_in_guild(guild_id, jday),
        select_merge: %{
          length:
            fragment("length(?) - length(replace(?, 'e', '')) as length", m.content, m.content),
          content: m.content
        },
        where: m.is_violation and not m.is_bypass,
        order_by: fragment("length desc")
      )
      |> Repo.one()

    if not is_nil(res) do
      multi
      |> Ecto.Multi.insert(
        :most_egregious_violation,
        Award.changeset(%Award{}, %{
          trophy:
            "#{mention(res)}: Most-worst violation (#{res.length} glyphs):\n#{quote_content(res)}",
          year_julian_day: jday,
          user_id: res.user_id,
          guild_id: guild_id
        })
      )
    else
      multi
    end
  end

  defp most_bypasses(multi, guild_id, jday) do
    res =
      from(m in today_in_guild(guild_id, jday),
        select_merge: %{
          bypass_count: fragment("count(?) as bypass_count", m.user_id)
        },
        where: m.is_bypass,
        group_by: m.user_id,
        order_by: fragment("bypass_count desc")
      )
      |> Repo.one()

    if not is_nil(res) do
      multi
      |> Ecto.Multi.insert(
        :most_bypasses,
        Award.changeset(%Award{}, %{
          trophy: "#{mention(res)}: Most bypassing via ! (#{res.bypass_count})",
          year_julian_day: jday,
          user_id: res.user_id,
          guild_id: guild_id
        })
      )
    else
      multi
    end
  end

  defp mention(u) when is_integer(u) or is_binary(u), do: "<@#{u}>"
  defp mention(res), do: mention(res.user_id)

  defp quote_content(content) when is_binary(content) do
    content
    |> String.split("\n")
    |> Enum.map(fn s -> "> " <> s end)
    |> Enum.join("\n")
  end

  defp quote_content(res), do: quote_content(res.content)
end
