# sfdx-lightning-test-service

# cli setup

# Option 1: SFDX standanlone executable
https://salesforce.quip.com/zHcMAbY3lpA8

#Option 2: (having some issues)
*brew install heroku*   (see https://devcenter.heroku.com/articles/heroku-cli)

*heroku plugins:install salesforcedx*  

# scratch org setup

*sfdx force:auth:web:login -d*  (login to hub org)

*sfdx force:org:create -s -f config/workspace-scratch-def.json -a scratch1*

# dev flow 

*sfdx force:source:push*  (push changes to scratch org)

*sfdx force:org:open*  (login to scratch org)

*sfdx force:testrunner:run  -f test/test-runner-config.json -c local -j integration*  (trigger integration test run)

