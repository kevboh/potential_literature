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
