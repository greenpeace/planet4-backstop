#!/usr/bin/env bash
set -euo pipefail

./replacevars.sh

cp /app/backstop_data/* /src/backstop_data/ -R

if (backstop test) then
  testresult=0;
else
  testresult=1;
fi;

cp /src/backstop_data/* /app/backstop_data/ -R

exit $testresult;
