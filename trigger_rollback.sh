#!/usr/bin/env bash
# shellcheck disable=SC2016
set -eu

repo="$1"
user=greenpeace
tag="$2"

json=$(jq -n \
  --arg VAL "$tag" \
  --arg RELEASE_STAGE "rollback" \
'{
  "tag": $VAL,
  "parameters": {
    "release_stage": $RELEASE_STAGE
  }
}')

echo "Triggering a rollback pipeline..."
echo "Build: ${user}/${repo}@${tag}"
echo "$json"
echo

curl \
  --header "Content-Type: application/json" \
  -d "$json" \
  -u "${CIRCLE_TOKEN}:" \
  -X POST \
  "https://circleci.com/api/v2/project/github/${user}/${repo}/pipeline"
