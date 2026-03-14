#!/bin/bash

if [ -z ${MINECRAFT_VERSION} ]; then
  echo "MINECRAFT_VERSION not set. Aborting"
  exit 1
fi;

PROJECT="paper"
USER_AGENT="cool-project/1.0.0 (contact@me.com)"
JAR_NAME=paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar

download_server () {
  # First check if the requested version has a stable build
  local BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds)

  # Check if the API returned an error
  if echo "$BUILDS_RESPONSE" | jq -e '.ok == false' > /dev/null 2>&1; then
    local ERROR_MSG=$(echo "$BUILDS_RESPONSE" | jq -r '.message // "Unknown error"')
    echo "Error: $ERROR_MSG"
    exit 1
  fi

  # Try to get a stable build URL for the requested version
  local PAPERMC_URL=$(echo "$BUILDS_RESPONSE" | jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')
  local FOUND_VERSION="$MINECRAFT_VERSION"


  if [ "$PAPERMC_URL" != "null" ]; then
    # Download the latest Paper version
    curl -o $JAR_NAME $PAPERMC_URL
    echo "Download completed (version: $FOUND_VERSION)"
  else
    echo "No stable builds available for any version :("
    exit 1
  fi
}

if [ ! -e ${JAR_NAME} ]; then
  download_server
fi

# Add RAM options to Java options if necessary
if [ ! -z "${MC_RAM}" ]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} ${JAVA_OPTS}"
fi

# Start server
exec java -server ${JAVA_OPTS} -jar ${JAR_NAME} --nogui
