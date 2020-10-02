#!/usr/bin/env bash
set -u

./replacevars.sh

cp /app/backstop_data/* /src/backstop_data/ -R

# Instead of relying to backstop exit code
# grep its output for ERROR
# https://github.com/garris/BackstopJS/issues/1145
echo "Running backstop"
backstop test >/tmp/backstop_report.txt
cat /tmp/backstop_report.txt

# If report has a match for "ERROR" keep a fail status
if [ "$(grep -c "ERROR" /tmp/backstop_report.txt)" == 0 ]; then
  echo "✅ All passed"
  testresult=0
else
  echo "❌ Errors found"
  testresult=1
fi

cp /src/backstop_data/* /app/backstop_data/ -R

# Get the git message for this commit
git_message=$(git --git-dir=/src/repo/.git log --format=%B -n 1 "$CIRCLE_SHA1")
echo "The git message is:"
echo "-----------"
echo "$git_message"
echo "-----------"
echo "The testresult is $testresult"

# if on staging visual tests pass, unhold the production pipeline.
if [ "$APP_ENVIRONMENT" = 'staging' ] && [ $testresult -eq 0 ] && [[ "$git_message" != *"[HOLD]"* ]]; then
  ./promote.sh "$CIRCLE_WORKFLOW_ID"
fi

exit 0
