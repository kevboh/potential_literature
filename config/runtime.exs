import Config

config :potential_literature, PotentialLiterature.Repo, database: System.get_env("DATABASE_URL")

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN")

config :potential_literature,
  summary_guild_id: System.get_env("SUMMARY_GUILD_ID"),
  summary_channel_id: System.get_env("SUMMARY_CHANNEL_ID")
