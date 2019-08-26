#!/usr/bin/env bash
set -euo pipefail

sed -i -e "s/APP_HOSTNAME/${APP_HOSTNAME}/g" /src/backstop.json
sed -i -e "s/APP_HOSTPATH/${APP_HOSTPATH}/g" /src/backstop.json
