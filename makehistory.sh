#!/usr/bin/env bash
set -euo pipefail

./replacevars.sh

backstop reference

cp /src/backstop_data /app/backstop_data/ -R
