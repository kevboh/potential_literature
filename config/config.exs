import Config

config :potential_literature,
  ecto_repos: [PotentialLiterature.Repo]

config :nostrum,
  gateway_intents: [
    :guild_messages,
    :guild_message_reactions,
    :direct_messages,
    :message_content
  ]

config :potential_literature, PotentialLiterature.Scheduler,
  jobs: [
    {"0 5 * * 3", {PotentialLiterature.Award, :ceremony, []}}
  ]
