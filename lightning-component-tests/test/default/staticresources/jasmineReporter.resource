/**
 * A sample reporter connected to Jasmine. This records information in various test run stages,
 * then add formatted test result to the DOM for other tools (e.g. SFDX) to grab.
 */
(function(global) {
    var UNDEFINED,
    exportObject;    

    /** Test result in TAP format (https://en.wikipedia.org/wiki/Test_Anything_Protocol) */
    var run_results_tap = "";

    /**
     * Test result for SFDX. This needs to be in format interpretable by SFDX lightning test run command.
     * Available fields include(case sensitive): FullName, Outcome (Pass/Fail/Skip/Disabled), Message, Runtime
     */
    var run_results_full = {"tests":[]};

    if (typeof module !== "undefined" && module.exports) {
        exportObject = exports;
    } else {
        exportObject = global.jasmineReporters = global.jasmineReporters || {};
    }

    function trim(str) { return str.replace(/^\s+/, "" ).replace(/\s+$/, "" ); }
    function elapsed(start, end) { return (end - start)/1000; }
    function isFailed(obj) { return obj.status === "failed"; }
    function isSkipped(obj) { return obj.status === "pending"; }
    function isDisabled(obj) { return obj.status === "disabled"; }

    /** performs a shallow copy of all props of `obj` onto `dupe` */
    function extend(dupe, obj) {
        for (var prop in obj) {
            if (obj.hasOwnProperty(prop)) {
                dupe[prop] = obj[prop];
            }
        }
        return dupe;
    }

    /**
     * Adds the test spec result to the full report.
     *
     * @param {string} tapReport TAP test result for the spec. 
     * @param {string} fullReport Full test result for the spec.
     */
    function log(tapReport, fullReport) {
        var con = global.console || console;
        if (con && con.log) {
            con.log(tapReport);
        }
        run_results_tap += tapReport + "\n";
        if (fullReport != null) {
            run_results_full.tests.push(fullReport);
        }
    }

    /**
     * Writes test result into a invisible div.
     * This is called twice, once for tap result, another for full result.
     *
     * @param {string} id The id of the div.
     * @param {string} The test result.
     */  
    function setHiddenDivContent(id, content) {
        var aDiv = document.getElementById(id);          

        if(!aDiv){            
            aDiv = document.createElement("div");
            aDiv.id = id;
            //aDiv.style = "display:none;";
            aDiv.style.display = "none";
            document.body.appendChild(aDiv); 
        }

        aDiv.innerHTML = content;  
        return aDiv;
    }

    exportObject.Reporter = function() {
        var self = this;
        self.started = false;
        self.finished = false;

        var startTime,
        endTime,
        currentSuite = null,
        totalSpecsExecuted = 0,
        totalSpecsSkipped = 0,
        totalSpecsDisabled = 0,
        totalSpecsFailed = 0,
        totalSpecsDefined,
        // when use fit, jasmine never calls suiteStarted / suiteDone, so make a fake one to use
        fakeFocusedSuite = {
                id: 'focused',
                description: 'focused specs',
                fullName: 'focused specs'
        };

        var __suites = {}, __specs = {};
        function getSuite(suite) {
            __suites[suite.id] = extend(__suites[suite.id] || {}, suite);
            return __suites[suite.id];
        }
        function getSpec(spec) {
            __specs[spec.id] = extend(__specs[spec.id] || {}, spec);
            return __specs[spec.id];
        }

        self.jasmineStarted = function(summary) {
            self.started = true;
            totalSpecsDefined = summary && summary.totalSpecsDefined || NaN;
            startTime = exportObject.startTime = new Date();
        };
        self.suiteStarted = function(suite) {
            suite = getSuite(suite);
            currentSuite = suite;
        };
        self.specStarted = function(spec) {
            if (!currentSuite) {
                // focused spec (fit) -- suiteStarted was never called
                self.suiteStarted(fakeFocusedSuite);
            }
            spec = getSpec(spec);
            totalSpecsExecuted++;
            spec._suite = currentSuite;
            this.specStartingTime = Date.now();
        };
        self.specDone = function(spec) {
            spec = getSpec(spec);

            var fullReport = {};
            fullReport.FullName =  spec._suite.description + ' : ' + spec.description;
            fullReport.Outcome = 'Pass';
            fullReport.RunTime = Date.now() - this.specStartingTime;

            var resultStr = 'ok ' + totalSpecsExecuted + ' - ' + spec._suite.description + ' : ' + spec.description;
            var failedStr = '';

            if (isFailed(spec)) {
                totalSpecsFailed++;
                resultStr = 'not ' + resultStr;
                for (var i = 0, failure; i < spec.failedExpectations.length; i++) {
                    failure = spec.failedExpectations[i];
                    failedStr += '\n  ' + trim(failure.message);
                }

                fullReport.Outcome = 'Fail';
                fullReport.Message = failedStr;
            }
            if (isSkipped(spec)) {
                totalSpecsSkipped++;
                var skipStr = ' # SKIP disabled by xit or similar';
                resultStr += skipStr;
                fullReport.Outcome = 'Skip';
                fullReport.Message = skipStr;
            }
            if (isDisabled(spec)) {
                totalSpecsDisabled++;
                var disableStr = ' # SKIP disabled by xit, ?spec=xyz or similar';
                fullReport.Outcome = 'Disabled';
                resultStr += disableStr;
            }

            log(resultStr, fullReport);
        };
        self.suiteDone = function(suite) {
            suite = getSuite(suite);
            if (suite._parent === UNDEFINED) {
                // disabled suite (xdescribe) -- suiteStarted was never called
                self.suiteStarted(suite);
            }
            currentSuite = suite._parent;
        };
        self.jasmineDone = function() {
            if (currentSuite) {
                // focused spec (fit) -- suiteDone was never called
                self.suiteDone(fakeFocusedSuite);
            }
            endTime = new Date();
            var dur = elapsed(startTime, endTime),
            totalSpecs = totalSpecsDefined || totalSpecsExecuted,
            disabledSpecs = totalSpecs - totalSpecsExecuted + totalSpecsDisabled;

            if (totalSpecsExecuted === 0) {
                log('1..0 # All tests disabled');
            } else {
                log('1..' + totalSpecsExecuted);
            }
            var diagStr = '#';
            diagStr = '# ' + totalSpecs + ' spec' + (totalSpecs === 1 ? '' : 's');
            diagStr += ', ' + totalSpecsFailed + ' failure' + (totalSpecsFailed === 1 ? '' : 's');
            diagStr += ', ' + totalSpecsSkipped + ' skipped';
            diagStr += ', ' + disabledSpecs + ' disabled';
            diagStr += ' in ' + dur + 's.';
            log(diagStr);
            //log('# NOTE: disabled specs are usually a result of xdescribe.');

            self.finished = true;
            // this is so phantomjs-testrunner.js can tell if we're done executing
            exportObject.endTime = endTime;

            //setHiddenDivContent("run_status", "Finished: Failures="+totalSpecsFailed);
            var tapResultDiv = setHiddenDivContent("run_results_tap", run_results_tap);
            tapResultDiv.setAttribute("data-failure-count", totalSpecsFailed);
            tapResultDiv.setAttribute("data-total-count", totalSpecsExecuted);

            setHiddenDivContent("run_results_full", JSON.stringify(run_results_full));
        };
    };
})(this);
