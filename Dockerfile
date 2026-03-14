FROM eclipse-temurin:25-jre

# Environment variables
ENV MC_RAM="" \
    JAVA_OPTS=""

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt update && apt-get --no-install-recommends install -y curl jq

RUN mkdir /papermc
WORKDIR /papermc
COPY start.sh /start.sh

# Container setup
EXPOSE 25565/tcp
EXPOSE 25565/udp
# Start script
ENTRYPOINT [ "/start.sh" ]