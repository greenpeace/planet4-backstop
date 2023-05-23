#!/usr/bin/env bash
set -euo pipefail

local_config=/src/repo/backstop-pages.json

if [ -f $local_config ]; then

  cp backstop.json backstop-backup.json

  node createConfig.js

  git config --global --add safe.directory /src

  git --no-pager diff backstop.json
fi
