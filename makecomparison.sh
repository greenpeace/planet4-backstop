#!/usr/bin/env bash
set -euo pipefail

./replacevars.sh

cp /app/backstop_data/* /src/backstop_data/ -R

backstop test

cp /src/backstop_data/* /app/backstop_data/ -R
