# Lightning Testing Service CLI Plugin

SFDX Pluging for Lightning Test Service

<!-- toc -->
* [Lightning Testing Service CLI Plugin](#lightning-testing-service-cli-plugin)
<!-- tocstop -->
  <!-- install -->
  <!-- usage -->
```sh-session
$ npm install -g lightning-testing-service
$ sfdx COMMAND
running command...
$ sfdx (-v|--version|version)
lightning-testing-service/0.0.0 darwin-x64 node-v12.10.0
$ sfdx --help [COMMAND]
USAGE
  $ sfdx COMMAND
...
```
<!-- usagestop -->
<!-- commands -->
* [`sfdx force2:lightning:test:install [-r <string>] [-t] [-w <number>] [-u <string>] [--apiversion <string>] [--json] [--loglevel trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]`](#sfdx-force2lightningtestinstall--r-string--t--w-number--u-string---apiversion-string---json---loglevel-tracedebuginfowarnerrorfataltracedebuginfowarnerrorfatal)
* [`sfdx force2:lightning:test:run [-r <string>] [-a <string>] [-d <filepath>] [-f <filepath>] [-o] [-t <number>] [-u <string>] [--apiversion <string>] [--json] [--loglevel trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]`](#sfdx-force2lightningtestrun--r-string--a-string--d-filepath--f-filepath--o--t-number--u-string---apiversion-string---json---loglevel-tracedebuginfowarnerrorfataltracedebuginfowarnerrorfatal)

## `sfdx force2:lightning:test:install [-r <string>] [-t] [-w <number>] [-u <string>] [--apiversion <string>] [--json] [--loglevel trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]`

install Lightning Testing Service unmanaged package in your org

```
USAGE
  $ sfdx force2:lightning:test:install [-r <string>] [-t] [-w <number>] [-u <string>] [--apiversion <string>] [--json] 
  [--loglevel trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]

OPTIONS
  -r, --releaseversion=releaseversion                                               release version of Lightning Testing
                                                                                    Service

  -t, --packagetype                                                                 type of unmanaged package. 'full'
                                                                                    option contains both jasmine and
                                                                                    mocha, plus examples

  -u, --targetusername=targetusername                                               username or alias for the target
                                                                                    org; overrides default target org

  -w, --wait=wait                                                                   number of minutes to wait for
                                                                                    installation status

  --apiversion=apiversion                                                           override the api version used for
                                                                                    api requests made by this command

  --json                                                                            format output as json

  --loglevel=(trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL)  [default: warn] logging level for
                                                                                    this command invocation

EXAMPLES
  $ sfdx force:lightning:test:install
  $ sfdx force:lightning:test:install -w 0 -r v1.0
  sfdx force:lightning:test:install -t jasmine
```

_See code: [lib/commands/force2/lightning/test/install.js](https://github.com/forcedotcom/LightningTestService/blob/v0.0.0/lib/commands/force2/lightning/test/install.js)_

## `sfdx force2:lightning:test:run [-r <string>] [-a <string>] [-d <filepath>] [-f <filepath>] [-o] [-t <number>] [-u <string>] [--apiversion <string>] [--json] [--loglevel trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]`

invoke Aura component tests

```
USAGE
  $ sfdx force2:lightning:test:run [-r <string>] [-a <string>] [-d <filepath>] [-f <filepath>] [-o] [-t <number>] [-u 
  <string>] [--apiversion <string>] [--json] [--loglevel 
  trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL]

OPTIONS
  -a, --appname=appname                                                             name of your Lightning test
                                                                                    application

  -d, --outputdir=outputdir                                                         directory path to store test run
                                                                                    artifacts: for example, log files
                                                                                    and test results

  -f, --configfile=configfile                                                       path to config file for the test

  -o, --leavebrowseropen                                                            leave browser open

  -r, --resultformat=resultformat                                                   test result format emitted to
                                                                                    stdout; --json flag overrides this
                                                                                    parameter

  -t, --timeout=timeout                                                             time (ms) to wait for results
                                                                                    element in dom

  -u, --targetusername=targetusername                                               username or alias for the target
                                                                                    org; overrides default target org

  --apiversion=apiversion                                                           override the api version used for
                                                                                    api requests made by this command

  --json                                                                            format output as json

  --loglevel=(trace|debug|info|warn|error|fatal|TRACE|DEBUG|INFO|WARN|ERROR|FATAL)  [default: warn] logging level for
                                                                                    this command invocation

EXAMPLES
  $ sfdx force:lightning:test:run
  $ sfdx force:lightning:test:run -a tests -r human
  $ sfdx force:lightning:test:run -f config/myConfigFile.json -d testResultFolder
```

_See code: [lib/commands/force2/lightning/test/run.js](https://github.com/forcedotcom/LightningTestService/blob/v0.0.0/lib/commands/force2/lightning/test/run.js)_
<!-- commandsstop -->
