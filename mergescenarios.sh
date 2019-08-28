#!/usr/bin/env bash
set -euo pipefail

if [ -f /src/repo/backstop-pages.json ]; then
  jq 'reduce inputs.scenarios as $s (.; .scenarios += $s)' backstop.json /src/repo/backstop-pages.json > combined.json
  jq 'reduce inputs.viewports as $s (.; .viewports += $s)' combined.json /src/repo/backstop-pages.json > combined2.json

  mv backstop.json backstop-backup.json
  mv combined2.json backstop.json
fi
