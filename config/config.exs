import Config

config :nostrum,
  gateway_intents: [
    :guild_messages,
    :guild_message_reactions,
    :direct_messages,
    :message_content
  ]
