#!/usr/bin/env bash
set -u

MSG_TYPE=":red_circle: A visualtests-compare job has failed!"
MSG_TITLE="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} @ ${CIRCLE_BRANCH:-${CIRCLE_TAG}}"
MSG_LINK="https://circleci.com/workflow-run/${CIRCLE_WORKFLOW_WORKSPACE_ID}"
MSG_TEXT="Requires manual approval"
MSG_COLOUR="#ff0000"

json=$(jq -n \
  --arg MSG_TYPE "$MSG_TYPE" \
  --arg MSG_TITLE "$MSG_TITLE" \
  --arg MSG_LINK "$MSG_LINK" \
  --arg MSG_TEXT "$MSG_TEXT" \
  --arg MSG_COLOUR "$MSG_COLOUR" \
  '{
  "text": $MSG_TYPE,
  "attachments": [
    {
      "title": $MSG_TITLE,
      "title_link": $MSG_LINK,
      "text": $MSG_TEXT,
      "color": $MSG_COLOUR
    }
  ]
}')

curl -X POST -H 'Content-Type: application/json' \
  --data "$json" \
  "${SLACK_NRO_WEBHOOK}"
