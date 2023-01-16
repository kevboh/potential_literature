# Potential Literature

A Discord bot to add [Oulipo](https://en.wikipedia.org/wiki/Oulipo)-style constraints to servers.

## Current Rules

1. No use of the letter `E` on Tuesdays. Messages containing the fifth glyph will be deleted (and DMed privately to the author, to preserve their sin).

Prefixing a message with `!` will skip rule enforcement, for emergencies.

## Development

`cp .env.example .env` and add your bot token. You can create an application [here](https://discord.com/developers/applications). Then:

```
mix deps.get
```

`iex -S mix` will start your bot locally with a connected REPL.

## Deploying via Fly.io

You'll need a volume named `db` for SQLite. If you’re trying to stick inside the free tier:

```
fly volumes create db --size 1
```

Set some secrets to prepare for initial release:

```
fly secrets set DISCORD_BOT_TOKEN="your-token" SUMMARY_GUILD_ID="your-guild-id" SUMMARY_CHANNEL_ID="your-main-channel-id"
```

The `DATABASE_URL` should be picked up by the `fly.toml` config. Then:

```
fly launch
```
