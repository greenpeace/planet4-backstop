#!/usr/bin/env bash
set -euo pipefail

# Default Docker CMD will be go.sh
if [ "$1" = "./go.sh" ]
then
	exec "$@"
else
  # Execute the custom CMD
  echo "Executing command:"
  echo "$*"
	exec /bin/sh -c "$*"
fi
