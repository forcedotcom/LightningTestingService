#!/usr/bin/env bash

# Test Runner profile determine by Pipelines stage
PROFILE="basic"
if [ $HEROKU_TEST_RUN_BRANCH = "master" ]
then
   PROFILE=$HEROKU_TEST_RUN_BRANCH
fi

# Setup base org info file
echo '{
    "Company": "HEROKU-CI",
    "Email": "t.dvornik@salesforce.com",
    "Country": "US",
    "LastName": "Heroku CI",
    "EnableTokenEncryption": false
}' > $XDG_DATA_HOME/.appcloud/workspace-config.json

echo "Invoking '$PROFILE' Test Runner profile..."
CMD="force:test -c test/test-runner-config.json -p $PROFILE -r tap"
heroku $CMD