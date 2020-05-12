aura-test
=========

SFDX Pluging for Lightning Test Service

[![Version](https://img.shields.io/npm/v/aura-test.svg)](https://npmjs.org/package/aura-test)
[![CircleCI](https://circleci.com/gh/forcedotcom/LightningTestService/tree/master.svg?style=shield)](https://circleci.com/gh/forcedotcom/LightningTestService/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/forcedotcom/LightningTestService?branch=master&svg=true)](https://ci.appveyor.com/project/heroku/LightningTestService/branch/master)
[![Codecov](https://codecov.io/gh/forcedotcom/LightningTestService/branch/master/graph/badge.svg)](https://codecov.io/gh/forcedotcom/LightningTestService)
[![Greenkeeper](https://badges.greenkeeper.io/forcedotcom/LightningTestService.svg)](https://greenkeeper.io/)
[![Known Vulnerabilities](https://snyk.io/test/github/forcedotcom/LightningTestService/badge.svg)](https://snyk.io/test/github/forcedotcom/LightningTestService)
[![Downloads/week](https://img.shields.io/npm/dw/aura-test.svg)](https://npmjs.org/package/aura-test)
[![License](https://img.shields.io/npm/l/aura-test.svg)](https://github.com/forcedotcom/LightningTestService/blob/master/package.json)

<!-- toc -->
* [Debugging your plugin](#debugging-your-plugin)
<!-- tocstop -->
<!-- install -->
<!-- usage -->
```sh-session
$ npm install -g aura-test
$ sfdx COMMAND
running command...
$ sfdx (-v|--version|version)
aura-test/0.0.0 darwin-x64 node-v12.10.0
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
<!-- debugging-your-plugin -->
# Debugging your plugin
We recommend using the Visual Studio Code (VS Code) IDE for your plugin development. Included in the `.vscode` directory of this plugin is a `launch.json` config file, which allows you to attach a debugger to the node process when running your commands.

To debug the `hello:org` command: 
1. Start the inspector
  
If you linked your plugin to the sfdx cli, call your command with the `dev-suspend` switch: 
```sh-session
$ sfdx hello:org -u myOrg@example.com --dev-suspend
```
  
Alternatively, to call your command using the `bin/run` script, set the `NODE_OPTIONS` environment variable to `--inspect-brk` when starting the debugger:
```sh-session
$ NODE_OPTIONS=--inspect-brk bin/run hello:org -u myOrg@example.com
```

2. Set some breakpoints in your command code
3. Click on the Debug icon in the Activity Bar on the side of VS Code to open up the Debug view.
4. In the upper left hand corner of VS Code, verify that the "Attach to Remote" launch configuration has been chosen.
5. Hit the green play button to the left of the "Attach to Remote" launch configuration window. The debugger should now be suspended on the first line of the program. 
6. Hit the green play button at the top middle of VS Code (this play button will be to the right of the play button that you clicked in step #5).
<br><img src=".images/vscodeScreenshot.png" width="480" height="278"><br>
Congrats, you are debugging!
