/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Force.com Continuous Integration CLI Test APIs to invoke tests and retrieve test results.
 *
 * $ force:lightning:test:run    - invokes tests of given Lightning test app name.
 *
 */

// ** external modules **
import { Logger, Messages, Org, SfdxError } from '@salesforce/core';
import * as BBPromise from 'bluebird';
import * as fs from 'fs';
import * as _ from 'lodash';
import * as mkdirpPkg from 'mkdirp';
import * as moment from 'moment';
import * as path from 'path';
import * as util from 'util';
import * as webdriverio from 'webdriverio';

const mkdirp = BBPromise.promisify(mkdirpPkg);

const writeFile = BBPromise.promisify(fs.writeFile);

import OrgOpenCommand = require('salesforce-alm/dist/lib/org/orgOpenCommand');
import Reporters = require('./reporter');
import SeleniumRunner = require('./seleniumRunner');
import TestResults = require('./testResults');

const TEST_RESULT_FILE_PREFIX = 'lightning-test-result';
const DEFAULT_TIMEOUT = 60000;

// Initialize Messages with the current plugin directory
Messages.importMessagesDirectory(__dirname);

// Load the specific messages for this file. Messages from @salesforce/command, @salesforce/core,
// or any library that is using the messages framework can also be loaded this way.
const messages = Messages.loadMessages('aura-test', 'run');

/**
 * Lightning TAP reporter implementation.
 */
class LightningTestTapReporter extends Reporters.TapReporter {
  public onStart(res) {
    if (res.tests && res.tests.length) {
      this.logTapStart(res.tests.length);
    }
  }

  public async onFinished(res) {
    res.tests.forEach(test => {
      this.logTapResult(test);
    });
  }

  public getFullTestName(testResult) {
    return testResult.FullName;
  }
}

/**
 * A list of the applicable reporter types
 */
// tslint:disable-next-line: variable-name
const ReporterTypes = {
  human: Reporters.HumanReporter,
  tap: LightningTestTapReporter,
  json: Reporters.JsonReporter,
  junit: Reporters.JUnitReporter
};

/**
 *  A container for the lightning test results that provides helpers around formating
 *  and logging test results.
 */
class LightningTestResults extends TestResults {
  constructor(testApi, tests, runResultSummaries, config) {
    super(
      testApi.testrunid,
      testApi.startTime,
      'force.lightning',
      tests,
      runResultSummaries,
      config
    );
  }

  public getTestContainerName() {
    return '';
  }

  public getTestNamespace(test) {
    return test.NamespacePrefix;
  }

  public getTestName(test) {
    return test.FullName;
  }
}

class LightningTestApi {
  private seleniumRunner: SeleniumRunner;
  private startTime: moment.Moment;
  // tslint:disable-next-line: no-any
  private configFileContent: any;
  // tslint:disable-next-line: no-any
  private reporter: any;
  private lightningTestResults: LightningTestResults;
  // tslint:disable-next-line: no-any
  private browser: any;
  // tslint:disable-next-line: no-any
  private session: any;
  // tslint:disable-next-line: ban-types
  private finishResolve: Function;

  /**
   * The API class that manages running Lightning tests.
   *
   * @param org {object} The org for running tests.
   */
  // tslint:disable-next-line: no-any
  constructor(private org: Org, private flags: any, private logger: Logger) {
    this.startTime = moment();
    this.session = undefined;
  }

  /**
   * Create the output directory the the test results will be stored if doesn't exist
   */
  public setupOutputDirectory() {
    const outputdir = this.flags.outputdir;
    if (!util.isNullOrUndefined(outputdir)) {
      return mkdirp(outputdir)
        .then(() => outputdir)
        .catch(error => {
          // It is ok if the directory already exist
          if (error.name !== 'EEXIST') {
            throw error;
          }
        });
    }
    return BBPromise.resolve();
  }

  public startSelenium(config = {}) {
    // start selenium here
    this.seleniumRunner = new SeleniumRunner();
    return this.seleniumRunner.start(config);
  }

  /**
   *
   * Initialize the test api to specify additional options and setup the
   * output directory if needed.
   *
   * @param {object} options The options used to run the tests. You can see a
   * list of valid options in the by looking at the defaults in the constructor.
   * @param {object} logger The logger object, which should typically be the
   * heroku cli.
   */
  public initialize() {
    if (this.flags.configfile) {
      this.configFileContent = JSON.parse(
        fs.readFileSync(this.flags.configfile).toString('utf8')
      );
    }

    if (!this.flags.resultformat) {
      this.flags.resultformat = 'human';
    }

    // Validate the reporter
    const reporter = ReporterTypes[this.flags.resultformat];
    if (!reporter) {
      return BBPromise.reject(
        new SfdxError(messages.getMessage('lightningTestInvalidReporter'))
        // Object.keys(ReporterTypes).join(',')
      );
    } else if (this.flags.resultformat === 'json') {
      // If the reporter is json, make sure the json flag is also set
      this.flags.json = true;
    }

    this.reporter = new reporter(this.logger);

    return BBPromise.all([
      this.startSelenium(this.configFileContent),
      this.setupOutputDirectory()
    ]);
  }

  /**
   * Run the specified tests.
   */
  public runTests() {
    this.reporter.log(
      this.flags.targetusername
        ? `Invoking Lightning tests using ${this.flags.targetusername}...`
        : 'Invoking Lightning tests...'
    );

    // Default configs
    let driverOptions = {
      desiredCapabilities: {
        browserName: 'chrome'
      },
      host: 'localhost',
      port: 4444
    };

    // tslint:disable-next-line: radix
    const timeout = parseInt(this.flags.timeout) || DEFAULT_TIMEOUT;
    let outputDivId = '#run_results_full';

    // Applying config file
    if (this.configFileContent != null) {
      if (this.configFileContent.webdriverio != null) {
        driverOptions = this.configFileContent.webdriverio;
      }

      if (this.configFileContent.outputDivId != null) {
        outputDivId = `#$${this.configFileContent.outputDivId}`;
      }
    }

    this.browser = webdriverio.remote(driverOptions);

    // Run lightning test apps with webdriverio and record results.
    return this.runTestAndExtractResults(outputDivId, timeout)
      .then(
        testResults => {
          if (testResults != null) {
            return this.retrieveAndStoreTestResults(testResults);
          }
          return BBPromise.reject(
            new SfdxError(
              messages.getMessage('lightningTestResultRetrievalFailed')
            )
          );
        },
        err =>
          BBPromise.reject(
            new SfdxError(err.message, messages.getMessage('testRunError'))
          )
      )
      .finally(() =>
        BBPromise.resolve()
          .then(() => {
            if (this.session && !this.flags.leavebrowseropen) {
              return this.browser.end();
            }

            return BBPromise.resolve(null);
          })
          .then(() => {
            if (this.seleniumRunner) {
              this.seleniumRunner.kill();
            }
          })
      );
  }

  // login and hit test app url; extract results from dom when complete
  public runTestAndExtractResults(outputDivId, timeout) {
    let appname = `/c/${
      this.flags.appname == null ? 'jasmineTests' : this.flags.appname
    }`;
    if (appname.indexOf('.app') < 0) {
      appname += '.app';
    }

    return this.getFrontDoorUrl(appname)
      .then(urlInfo =>
        this.startSessionWaitForDiv(urlInfo.url, appname, outputDivId, timeout)
      )
      .then(() => this.extractTestResults(outputDivId))
      .then(testResultsStr =>
        this.generateResultSummary(JSON.parse(testResultsStr))
      );
  }

  public startSessionWaitForDiv(url, appname, outputDivId, timeout) {
    return this.browser.init().then(newSession => {
      this.session = newSession;
      this.logger.info(`Loading ${appname}...`);
      return this.browser.url(url).waitForExist(outputDivId, timeout);
    });
  }

  public extractTestResults(outputDivId) {
    return this.browser.getHTML(outputDivId, false);
  }

  public getFrontDoorUrl(appname) {
    // retrieving lightning test app url with credential params.
    const orgOpenCommand = new OrgOpenCommand();
    const context = {
      org: this.org,
      urlonly: true,
      path: appname
    };

    return orgOpenCommand
      .validate(context)
      .then(() => orgOpenCommand.execute(context))
      .then(urlInfo => urlInfo);
  }

  public generateResultSummary(testResults) {
    const summary = {
      StartTime: this.startTime,
      TestTime: 0,
      TestExecutionTime: 0,
      UserId: '' // TODO
    };
    testResults.summary = [summary];

    // extract duration time for dom
    const durationTimeRegexp = new RegExp(/([0-9\.]+)/gi);

    return this.extractDuration().then(duration => {
      if (!util.isNullOrUndefined(duration)) {
        const parsedDuration = durationTimeRegexp.exec(duration);
        if (parsedDuration != null && parsedDuration.length > 0) {
          summary.TestTime = parseFloat(parsedDuration[0]) * 1000; // convert to ms
          summary.TestExecutionTime = summary.TestTime;
        }
      }

      return testResults;
    });
  }

  public extractDuration() {
    return this.browser.getText('.jasmine-duration', true).catch(() => {
      /* ignore */
    });
  }

  /**
   * Retrieve the test results then store them by logging the test results
   * to the client and filesystem.
   */
  public retrieveAndStoreTestResults(results) {
    this.reporter.log('Preparing test results...');

    const orgConfig = {
      orgId: this.org.getOrgId(),
      instanceUrl: '',
      username: this.org.getUsername()
    };

    try {
      this.lightningTestResults = new LightningTestResults(
        this,
        results.tests,
        results.summary,
        orgConfig
      );
      if (this.flags.outputdir) {
        return this.logTestArtifacts();
      }

      if (this.reporter) {
        this.reporter.emit('start', this.lightningTestResults);
        this.reporter.emit('finished', this.lightningTestResults);
      }

      this.reporter.log('Test run complete');

      const json = this.lightningTestResults.toJson();
      // Check if it was kicked off via runTest
      if (util.isFunction(this.finishResolve)) {
        return this.finishResolve(json);
      } else {
        return json;
      }
    } catch (err) {
      err['name'] = 'TestResultRetrievalFailed';
      err['message'] = messages.getMessage(
        'lightningTestResultRetrievalFailed',
        [err.message]
      );
      throw err;
    }
  }

  /**
   * Log test results to the console and/or the filesystem depending on the options
   */
  public logTestArtifacts() {
    this.reporter.log(
      `Writing test results to files to ${this.flags.outputdir}...`
    );

    // write test results files - junit and json
    if (util.isString(this.flags.outputdir)) {
      let json;
      const files = [];

      // Write junit file
      const junit = {
        format: 'JUnit',
        file: path.join(
          this.flags.outputdir,
          `${TEST_RESULT_FILE_PREFIX}-junit.xml`
        )
      };

      return writeFile(junit.file, this.lightningTestResults.generateJunit())
        .bind(this)
        .then(() => {
          files.push(junit);

          // Write JSON file
          json = {
            format: 'JSON',
            file: path.join(
              this.flags.outputdir,
              `${TEST_RESULT_FILE_PREFIX}.json`
            )
          };
          return writeFile(
            json.file,
            JSON.stringify(this.lightningTestResults.toJson(), null, 4)
          );
        })
        .then(() => {
          files.push(json);

          this.reporter.logTable('Test Reports', files, [
            { key: 'format', label: 'Format' },
            { key: 'file', label: 'File' }
          ]);
        });
    }

    return BBPromise.resolve();
  }
}

export = LightningTestApi;
