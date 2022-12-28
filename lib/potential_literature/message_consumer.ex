defmodule PotentialLiterature.MessageConsumer do
  @moduledoc """
  The main entrypoint for the Potential Literature bot.
  Handles incoming messages and responds accordingly.
  """

  use Nostrum.Consumer
  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # IO.inspect(msg)

    if is_inspectable?(msg) and is_violation?(msg) do
      # coward's mode
      # Api.create_reaction!(msg.channel_id, msg.id, "🔕")

      Api.delete_message!(msg)
      {:ok, ch} = Api.create_dm(msg.author.id)

      embed =
        %Embed{}
        |> Embed.put_title("Fifth Glyph Follows")
        |> Embed.put_description(msg.content)

      Api.create_message!(ch.id, content: random_admonition(), embeds: [embed])
      :ok
    else
      :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end

  defp is_inspectable?(msg) do
    # ignore messages without a guild_id (i.e. DMs),
    # those not occuring on a tuesday (the 2nd day of the week),
    # and those prefixed with !
    dow =
      msg.timestamp
      |> DateTime.shift_zone!("America/New_York", Tz.TimeZoneDatabase)
      |> Date.day_of_week()

    not is_nil(msg.guild_id) and
      dow == 2 and
      not String.starts_with?(msg.content, "!")
  end

  defp is_violation?(msg) do
    c =
      msg.content
      |> String.downcase()
      |> String.normalize(:nfd)
      |> String.codepoints()

    "e" in c
  end

  @admonitions %{
    1 => "And I thought so highly of you.",
    2 => "Must you afflict us so?",
    3 => "Try again, without that horrid symbol.",
    4 => "It pains us, that form!",
    5 => "Alas, but not a lack.",
    6 => "I cannot stand idly by whilst you fling that glyph about!"
  }

  defp random_admonition do
    idx = :rand.uniform(6)
    @admonitions[idx]
  end
end
