# sfdx-lightning-test-service


1- heroku force:auth:web:login -d

2- heroku force:org:create -s -f config/workspace-scratch-def.json -a scratch1

3- heroku force:source:push 

4- heroku force:test:run -f test/test-runner-config.json -c local -j integration 

