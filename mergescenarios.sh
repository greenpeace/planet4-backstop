#!/usr/bin/env bash
set -euo pipefail

if [ -f /src/repo/backstop-pages.json ]; then
  jq -s '.[0].scenarios = [.[].scenarios | add] | .[0]' backstop.json /src/repo/backstop-pages.json > combined.json

  mv backstop.json backstop-backup.json
  mv combined.json backstop.json
fi
