/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { blue, green, red } from 'colors';
import * as glob from 'glob';
import * as _ from 'lodash';
import * as path from 'path';
import * as util from 'util';

import { UX } from '@salesforce/command';
import { Dictionary } from '@salesforce/ts-types';

// expecting 'Class.[ns].<ClassName>.<MethodName>: line <Number>, column <Number>'
const CLASS_LOCATION_REGEX = new RegExp(
  'Class(?:\\.([\\w]*))?\\.([\\w]*)\\.([\\w]*): line ([0-9]*), column ([0-9]*)'
);

/**
 * A Reporter outputs progress and results to stdout and, optionally, different
 * streams. This is an abstract class. Different implementations can specify
 * the output format hey want to report for the command.
 *
 * Many events can call into a reporter, which means that async events on
 * a progress event may not finish before the next event is sent in. For example:
 *    1. a client (like streaming) is listening for events
 *    2. a progress event comes in and emits progress on the reporter and waits
 *    3. a finish event comes in and emits finish on the reporter and waits
 *
 * Even though the #2 is waiting, node will still hit #3 because the way events
 * work in node. Therefore, if any part of the reporter needs to preform an async
 * operation, it must be added to the operations array.
 *    this.operations.push(promise);
 *
 * Finish will wait for all operations to finish before returning.
 */
export class Reporter {
  // tslint:disable-next-line: no-any variable-name
  public static Types: Dictionary<any>;

  // TODO: proper property typing
  // tslint:disable-next-line: no-any
  [property: string]: any;

  constructor(private logger: UX) {
    this.streams = [];

    this.operations = [];
  }

  /**
   * We must pipe stdout to the stream while this reporter lives because
   * there are several calls to logger (like table) which does a lot of logic
   * before writing directly to stdout.
   */
  public addStream(stream) {
    if (stream) {
      this.streams.push(stream);
    }
  }

  public log(msg?) {
    this.logger.log(msg);
    this.logToStreams(msg);
  }

  public logToStreams(msg) {
    this.streams.forEach(stream => stream.write(`${msg}\n`));
  }

  /**
   * Log some test information to the console, but only log when json is not
   * specified. Otherwise the only output should be in json format which will
   * print to the console when the command returns on the command handler.
   * @param {string} header The header for the table OR a string if no table
   *    (object) is specified.
   * @param {object|array} data The data to display in the table. Data will be
   *    converted to an array if an object is passed in.
   * @param {array} columns An array of column information, such as key, label,
   * and formatter.
   */
  public logTable(header, data, columns) {
    let rows = data;

    // Tables require arrays, so convert objects to arrays
    if (util.isObject(data) && !util.isArray(data)) {
      rows = [];
      Object.keys(data).forEach(key => {
        // Turn keys into titles; i.e. testRunId to Test Run Id
        const title = _.map(_.kebabCase(key).split('-'), _.capitalize).join(
          ' '
        );
        rows.push({ key: title, value: `${data[key]} ` });
      });
    }

    this.log(`=== ${blue(header)}`);
    this.logger.table(rows, {
      columns,
      printLine: (...args) => {
        this.log(...args);
      }
    });
    this.log('');
  }

  public onStart(data?) {
    // noop
  }

  /**
   * Does this Reporter need progress information.
   */
  get progressRequired() {
    return util.isFunction(this.onProgress);
  }

  /**
   * Determine if this is a specific Reporter type instance.
   *
   * @param {class} type The type of Reporter to check if this is an instanceof.
   */
  public isType(type) {
    return this instanceof type;
  }

  /**
   * The function to call when the command has finished.
   *
   * @param {Object} results The completed results
   */
  // Adding data here so prevent typescript errors when including data
  // in onFinished.
  public onFinished(data?) {
    // eslint-disable-line no-unused-vars
    this.streams.forEach(stream => stream.close());

    let promise = Promise.resolve();

    this.operations.forEach(op => {
      promise = promise.then(() => op);
    });
    return promise;
  }

  /**
   * The type of output this reporter produces, like the file format which
   * makes this useful for file extensions.
   * i.e. xml, json, txt, etc.
   *
   * This method must be implemented.
   *
   * @param {Object} results The completed results
   */
  public getFormat() {
    throw new Error('NOT IMPLEMENTED');
  }

  public emit(event, data) {
    const funcName = `on${_.capitalize(event)}`;
    if (_.isFunction(this[funcName])) {
      return this[funcName](data);
    }
    return Promise.resolve();
  }
}

/**
 * Output the test results in a human readable way
 */
export class HumanReporter extends Reporter {
  constructor(parentLogger, config) {
    super(parentLogger);
    this.config = config;
    this.testFilePathMap = new Map();
  }

  public getTable() {
    return [
      { key: 'FullName', label: 'Test Name' },
      {
        key: 'Outcome',
        label: 'Outcome',
        format: outcome => {
          if (outcome === 'Pass') {
            return green(outcome);
          }
          return red(outcome);
        }
      },
      {
        key: 'Message',
        label: 'Message',
        format: (msg, row) => {
          if (util.isString(msg)) {
            // output message followed by full stacktrack, if available
            return `${red(msg)}${
              !_.isEmpty(row.StackTrace) ? `\n${row.StackTrace}` : ''
            }`;
          }
          return '';
        }
      },
      { key: 'RunTime', label: 'Runtime (ms)' }
    ];
  }

  public logResultsTable(testResults) {
    const table = this.getTable();
    this.logTable('Test Results', testResults.tests, table);
  }

  public logSummaryTable(testResults) {
    this.logTable('Test Summary', testResults.summary, [
      { key: 'key', label: 'Name' },
      { key: 'value', label: 'Value' }
    ]);
  }

  // if failures, log "Failures" table w/ message and fullpath stacktrace
  public logFailuresTable(testResults) {
    if (!testResults.tests) {
      return;
    }

    const failures = testResults.tests.filter(
      test => util.isString(test.Message) && !_.isEmpty(test.StackTrace)
    );

    if (failures && failures.length > 0) {
      this.logTable('Failures', failures, [
        { key: 'FullName', label: 'FullName' },
        {
          key: 'Message',
          label: 'Message',
          format: (msg, row) => {
            const sourceLinks = [];
            const stacks = row.StackTrace.split('\n');
            if (stacks.length > 0) {
              stacks.forEach(stack => {
                let location = '';
                const regExMatch = CLASS_LOCATION_REGEX.exec(stack);
                if (regExMatch && regExMatch.length === 6) {
                  // first match is optional namespace
                  const filepath = this._findFile(`${regExMatch[2]}.cls`);
                  if (filepath && filepath.length > 0) {
                    // format specific to vscode for link to source editor
                    const delimiter = ':';
                    location = `${filepath[0]}${delimiter}${regExMatch[4]}${delimiter}${regExMatch[5]}`;
                  }
                }

                sourceLinks.push(location);
              });
            }

            return `${red(msg)}\n${sourceLinks.join('\n')}`;
          }
        }
      ]);
    }
  }

  // find file in configured package source dirs
  public _findFile(filename) {
    // see if we've already scanned for this file
    let filepaths = this.testFilePathMap.get(filename);
    if (filepaths) {
      return filepaths;
    }

    filepaths = [];
    const workspaceConfig = this.config.getAppConfigIfInWorkspace();
    const packageDirs = workspaceConfig.packageDirectoryPaths;
    for (const packageDir of packageDirs) {
      filepaths = glob.sync(path.join(packageDir, '**', filename));
      if (filepaths && filepaths.length > 0) {
        // stash filepath for re-use
        this.testFilePathMap.set(filename, filepaths);
        break;
      }
    }

    return filepaths;
  }

  public logTables(testResults) {
    this.logResultsTable(testResults);
    this.logFailuresTable(testResults);
    this.logSummaryTable(testResults);
  }

  public onFinished(testResults) {
    this.logTables(testResults);
    return super.onFinished(testResults);
  }

  public getFormat() {
    return 'txt';
  }
}

/**
 * This is a special reporter that only logs to streams. This is because the CLI has
 * a global 'json' flag that outputs JSON to stdout, and requires that the JSON
 * be returned from the command. So we do not log to stdout here so we don't print JSON
 * twice.
 */
export class JsonReporter extends Reporter {
  public onFinished(testResults) {
    // We can only log to streams because the CLI process logs the json to stdout.
    this.logToStreams(JSON.stringify(testResults.toJson()));
    return super.onFinished(testResults);
  }
  public log(msg) {} // eslint-disable-line no-unused-vars
  public logTable(header, data, columns) {} // eslint-disable-line no-unused-vars
  public getFormat() {
    return 'json';
  }
}

/**
 * No-op report, but does provide logging utility.
 */
export class NoOpReporter extends Reporter {
  public addStream() {}
}

/**
 * Outputs test results in JUnit format, particularly useful for CI tools.
 */
export class JUnitReporter extends Reporter {
  public onFinished(testResults) {
    // Log the junit to all streams
    super.log(testResults.generateJunit());
    return super.onFinished(testResults);
  }
  public log() {
    // We print all junit at the end of the run
  }
  public getFormat() {
    return 'xml';
  }
}
/**
 * A TAP reporter. https://testanything.org
 *
 * TAP is specifically useful for streaming results to the client, so this
 * reporter listens for test progress.
 */
export class TapReporter extends Reporter {
  constructor(parentLogger) {
    super(parentLogger);
    this.counter = 1;
  }

  /**
   * Logs messages that are ignored by TAP parsing, eg directives, comments,
   * and general log lines.
   *
   * Use logTap to log parsable TAP output.
   *
   * @param msg
   */
  public log(msg) {
    super.log(`# ${msg}`);
  }

  public logTap(msg) {
    super.log(msg);
  }

  // table not support in TAP
  public logTable(header, data, columns) {} // eslint-disable-line no-unused-vars

  // logs 1..<given num of tests>
  public logTapStart(testCnt) {
    this.logTap(`1..${testCnt}`);
  }

  /**
   * Receive notifications on progress to output TAP lines as the tests finish.
   * NOTE: This will use more API calls since it will query the queue items every
   *  streaming event.
   */
  public async onProgress(data?) {}

  /**
   * Construct TAP formatted line.
   *
   * @param testResult
   */
  public logTapResult(testResult) {
    // First time we have heard from this result, so print
    let output = '';
    if (testResult.Outcome !== 'Pass') {
      output += 'not ';
    }
    output += `ok ${this.counter++} ${this.getFullTestName(testResult)}`;
    this.logTap(output);

    if (testResult.Outcome !== 'Pass') {
      if (testResult.Message) {
        const startsWithNewlineRegex = new RegExp(/^[/\r\n|\r|\n][\w]*/gim);
        if (startsWithNewlineRegex.test(testResult.Message)) {
          // lightning tests return newline delimited messages
          testResult.Message.split(/\r\n|\r|\n/g).forEach(msg => {
            if (msg && msg.length > 0) {
              this.log(msg.trim());
            }
          });
        } else {
          this.log(testResult.Message);
        }
      } else {
        this.log('Unknown error');
      }

      if (testResult.StackTrace) {
        testResult.StackTrace.split('\n').forEach(line => {
          this.log(line);
        });
      }
    }
  }

  public getFullTestName(testResult) {
    // eslint-disable-line no-unused-vars
    throw new Error('EXPECTED IMPLEMENTATION');
  }

  public getFormat() {
    return 'txt';
  }
}
