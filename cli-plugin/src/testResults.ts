/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

// ** external modules **
import * as _ from 'lodash';
import * as moment from 'moment';
import * as util from 'util';

/**
 *  A container for the test results that provides helpers around formating
 *  and logging test results.
 */
class TestResults {
  // TODO: proper property typing
  [property: string]: any;

  constructor(testrunid, startTime, suitename, tests, runResultSummaries, config, passStr = 'Pass', skipStr = 'Skip') {
    if (util.isNullOrUndefined(tests) || tests.length <= 0) {
      throw new Error('No test results found');
    }

    this.testrunid = testrunid;
    this.suitename = suitename;
    this.tests = tests;
    this.config = config;
    this.passStr = passStr;

    // combine test and method names for fullname
    this.tests.forEach(test => {
      if (!test.FullName) {
        const containerName = this.getTestContainerName(test);
        test.FullName = `${containerName ? `${containerName}.` : ''}${this.getTestName(test)}`;
      }
    });

    // sort by fullname
    this.tests.sort((test1, test2) => {
      const testName1 = test1.FullName.toUpperCase();
      const testName2 = test2.FullName.toUpperCase();

      if (testName1 < testName2) {
        return -1;
      }

      if (testName1 > testName2) {
        return 1;
      }

      return 0;
    });

    this.failures = this.tests.filter(test => test.Outcome !== passStr && test.Outcome !== skipStr);
    this.skips = this.tests.filter(test => test.Outcome === skipStr);

    // should just have 1 test summary given single test run id
    const runResultSummary = runResultSummaries && runResultSummaries.length > 0 ? runResultSummaries[0] : null;

    this.startTime = startTime;
    // time of cli cmd invocation
    this.commandTime = moment().diff(this.startTime);
    // start time per run summary
    this.testStartTime =
      runResultSummary !== null ? moment.parseZone(runResultSummary.StartTime).local() : this.startTime;
    // total time per run summary
    this.testTotalTime = runResultSummary !== null ? runResultSummary.TestTime : 0;
    // sum of all test.RunTime
    this.testExecutionTime =
      runResultSummary !== null && runResultSummary.TestExecutionTime
        ? runResultSummary.TestExecutionTime
        : tests.reduce((result, test) => result + (test.RunTime ? test.RunTime : 0), 0);

    this.userId = runResultSummary !== null ? runResultSummary.UserId : '';
  }

  get outcome() {
    return this.totalFailed > 0 ? 'Failed' : 'Passed';
  }

  get total() {
    return this.tests.length;
  }

  get totalFailed() {
    return this.failures.length;
  }

  get totalPassed() {
    return this.total - this.totalFailed - this.totalSkipped;
  }

  get totalSkipped() {
    return this.skips.length;
  }

  get passRate() {
    return `${Math.round((this.totalPassed / (this.total - this.totalSkipped)) * 100)}%`;
  }

  get failRate() {
    return `${Math.round((this.totalFailed / (this.total - this.totalSkipped)) * 100)}%`;
  }

  get summary() {
    const summary: any = {
      outcome: this.outcome,
      testsRan: this.total,
      passing: this.totalPassed,
      failing: this.totalFailed,
      skipped: this.totalSkipped,
      passRate: this.passRate,
      failRate: this.failRate,
      testStartTime: this.testStartTime.format('lll'),
      testExecutionTime: `${this.testExecutionTime} ms`,
      testTotalTime: `${this.testTotalTime} ms`,
      commandTime: `${this.commandTime} ms`,
      hostname: this.config.instanceUrl,
      orgId: this.config.orgId,
      username: this.config.username
    };

    if (this.testrunid) {
      summary.testRunId = this.testrunid;
    }

    if (this.userId) {
      summary.userId = this.userId;
    }

    if (this.coverage) {
      summary.testRunCoverage = this.coverage.summary.testRunCoverage;
      summary.orgWideCoverage = this.coverage.summary.orgWideCoverage;
    }

    return summary;
  }

  toJson() {
    const result: any = {
      summary: this.summary,
      tests: this.tests
    };

    if (this.coverage) {
      result.coverage = this.coverage;
    }

    return result;
  }

  generateJunit() {
    function msToSeconds(ms) {
      return _.round(ms / 1000, 2);
    }

    const timeProps = ['testExecutionTime', 'testTotalTime', 'commandTime'];

    // reference schema https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd
    let junit = '<?xml version="1.0" encoding="UTF-8"?>\n';
    junit += `<testsuites>\n`;
    // REVIEWME: attempt to replace "(root)" via name and classname
    junit += `    <testsuite name="${this.suitename}" `;
    junit += `timestamp="${this.testStartTime.format()}" `;
    junit += `hostname="${this.config.instanceUrl}" `;
    junit += `tests="${this.total}" `;
    junit += `failures="${this.totalFailed}"  `;
    junit += 'errors="0"  '; // FIXME
    junit += `time="${msToSeconds(this.testExecutionTime)}"`;
    junit += '>\n';
    junit += '        <properties>\n';

    _.forEach(this.summary, (value, key) => {
      if (_.includes(timeProps, key)) {
        value = `${msToSeconds(parseInt(value.split(' '), 10))} s`;
      }
      junit += `            <property name="${key}" value="${value}"/>\n`;
    });
    junit += '        </properties>\n';

    this.tests.forEach(test => {
      const success = test.Outcome === this.passStr;
      let classname = this.getTestContainerName(test);
      if (this.getTestNamespace(test)) {
        classname = this.getTestNamespace(test) + classname;
      }
      junit += `        <testcase name="${this.getTestName(test)}" classname="${classname}" time="${
        test.RunTime ? msToSeconds(test.RunTime) : 0
      }">\n`;

      if (!success) {
        junit += `            <failure message="${_.escape(test.Message)}">`;
        if (test.StackTrace) {
          junit += `<![CDATA[${test.StackTrace}]]>`;
        }
        junit += '</failure>\n';
      }
      junit += '        </testcase>\n';
    });
    junit += '    </testsuite>\n';
    junit += '</testsuites>\n';
    return junit;
  }

  // implementors return test class name from given test object
  getTestContainerName(test): string {
    // eslint-disable-line no-unused-vars
    throw new Error('EXPECTED IMPLEMENTATION');
  }

  // implementors return test namespace from given test object
  getTestNamespace(test): string {
    // eslint-disable-line no-unused-vars
    throw new Error('EXPECTED IMPLEMENTATION');
  }

  // implementors return test name from given test object
  getTestName(test): string {
    // eslint-disable-line no-unused-vars
    throw new Error('EXPECTED IMPLEMENTATION');
  }
}

export = TestResults;
