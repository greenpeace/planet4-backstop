#!/usr/bin/env bash
set -euo pipefail

if [ -f /src/$CIRCLE_PROJECT_REPONAME/backstop-pages.json ]; then
  jq -s '.[0].scenarios = [.[].scenarios | add] | .[0]' backstop.json $CIRCLE_PROJECT_REPONAME/backstop-pages.json > combined.json

  mv backstop.json backstop-backup.json
  mv combined.json backstop.json
fi
