#!/usr/bin/env bash
# shellcheck disable=SC2016
set -eu

repo=$1
user=greenpeace
tag=$2
release_init=$3
release_hold=$4
release_finish=$5


json=$(jq -n \
  --arg VAL "$tag" \
  --argjson RELEASE_INIT $release_init \
  --argjson RELEASE_HOLD $release_hold \
  --argjson RELEASE_FINISH $release_finish \
'{
	"branch": $VAL,
  "parameters": {
    "run_release_init": $RELEASE_INIT,
    "run_release_hold": $RELEASE_HOLD,
    "run_release_finish": $RELEASE_FINISH
  }
}')

echo "Build: ${user}/${repo}@${tag}"
echo "RELEASE_INIT: $release_init"
echo "RELEASE_HOLD: $release_hold"
echo "RELEASE_FINISH: $release_finish"

curl \
  --header "Content-Type: application/json" \
  -d "$json" \
  -u "${CIRCLE_TOKEN}:" \
  -X POST \
  "https://circleci.com/api/v2/project/github/${user}/${repo}/pipeline"
