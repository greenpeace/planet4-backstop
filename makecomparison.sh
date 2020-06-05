#!/usr/bin/env bash
set -u

./replacevars.sh

cp /app/backstop_data/* /src/backstop_data/ -R

# Instead of relying to backstop exit code
# grep its output for ERROR
# https://github.com/garris/BackstopJS/issues/1145
echo "Running backstop"
backstop test > /tmp/backstop_report.txt
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

#Get the git message for this commit
git_message=$(git --git-dir=/src/repo/.git log --format=%B -n 1 "$CIRCLE_SHA1")
echo "The git message is:"
echo "-----------"
echo "$git_message"
echo "-----------"
echo "The testresult is $testresult"

# if the APP_ENVIRONMENT is staging AND
#     if tests are successfull and you find the text [AUTO-PROCEED] in the commit message,
#      trigger the workflow 'release-finish'
#      else trigger the workflow 'release-hold-and-finish'
if [ "$APP_ENVIRONMENT" = "staging" ]; then
  if [ $testresult = 0 ]  && [[ $git_message == *"[AUTO-PROCEED]"* ]]; then
    echo "The auto-proceed message exists and the testresult is 0"
    #Parameter 3 is release_init
    #Parameter 4 is release_hold
    #Parameter 5 is release_finish
    ./trigger_api.sh "$CIRCLE_PROJECT_REPONAME" "$CIRCLE_BRANCH" false false true
  else
    echo "Either the auto-proceed does not exist or the testresult is not 0"
    #Parameter 3 is release_init
    #Parameter 4 is release_hold
    #Parameter 5 is release_finish
    ./trigger_api.sh "$CIRCLE_PROJECT_REPONAME" "$CIRCLE_BRANCH" false true false
  fi;
fi;

exit $testresult;
