# sfdx-lightning-test-service

# cli setup

*brew install heroku*   (see https://devcenter.heroku.com/articles/heroku-cli)

*heroku plugins:install salesforcedx@prerelease*  (plugin name will change as they come out of prerelease)

# scratch org setup

*heroku force:auth:web:login -d*  (login to hub org)

*heroku force:org:create -s -f config/workspace-scratch-def.json -a scratch1*

# dev flow 

*heroku force:source:push*  (push changes to scratch org)

*heroku force:org:open*  (login to scratch org)

*heroku force:testrunner:run  -f test/test-runner-config.json -c local -j integration*  (trigger integration test run)

