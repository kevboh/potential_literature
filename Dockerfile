# Adapted from https://github.com/fly-apps/hello_elixir/blob/main/Dockerfile

ARG BUILDER_IMAGE="hexpm/elixir:1.14.2-erlang-25.1.2-debian-bullseye-20221004-slim"
ARG RUNNER_IMAGE="debian:bullseye-20221004-slim"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/
RUN mix deps.compile

# Compile the release
COPY priv priv
COPY lib lib

RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales sqlite3 \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel ./

COPY --chown=root:root entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
RUN chown nobody /entrypoint.sh

USER nobody

# Create a symlink to the command that starts your application. This is required
# since the release directory and start up script are named after the
# application, and we don't know that name.
RUN set -eux; \
  ln -nfs /app/$(basename *)/bin/$(basename *) /app/entry

CMD /entrypoint.sh
