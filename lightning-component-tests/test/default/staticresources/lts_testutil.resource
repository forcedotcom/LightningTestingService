/**
 * This test util aims to reduce the boiler plate code needed in the test specs by providing helper methods for common test patterns.
 * Tests reference the helper methods via '$T'.
 */
(function (global) {
    global.$T = function $T() { };

    var cmpsToCleanup = [];
    var contexualRunner;

    /**
     * Waits for the function to finish executing.
     * 
     * @param {function} fn The function to be executed.
     * @param {?number} timeout The total timeout for the wait.
     * @param {?number} interval The interval.
     * @returns {Promise} The wait result.
     */
    $T.waitFor = function (fn, timeout, interval) {
        timeout = timeout || 3000;
        interval = interval || 50;

        var endTime = new Date().getTime() + timeout;
        return new Promise(function (resolve, reject) {
            (function poll() {
                var res = fn();
                if (res) {
                    resolve(res);
                } else if (new Date().getTime() < endTime) {
                    setTimeout(poll, interval);
                } else {
                    reject(new Error("Timed out after " + timeout
                        + "ms waiting for: " + fn));
                }
            })();
        });
    }

    /**
     * Creates the Lightning component, adds it to the list of components to be cleared,
     * and render it into the specified DOM element.
     * 
     * @param {string} descriptor The descriptor of the component to be rendered.
     * @param {Object.<string, Object>} attributes The attributes to be set to the component.
     * @param {boolean} requiresRendering If component rendering is required. Optional.
     * @returns {Promise} component creation or rendering result, depending on whether renderInto is specified
     */
    $T.createComponent = function (descriptor, attributes, requiresRendering) {
        var renderInto = requiresRendering ? document.getElementById("renderTestComponents") : null;
        var callback = function (resolve, reject) {
            runInsideCallbackClosure(function () {
                $A.createComponent(descriptor, attributes, function (component, status, error) {
                    if (status === "SUCCESS") {
                        cmpsToCleanup.push(component.getGlobalId());
                        if (renderInto) {
                            var renderingContainer = $A.getComponent(renderInto);
                            if (!renderingContainer) {
                                throw new Error("Could not find valid component to render into: " + renderInto);
                            }
                            var body = renderingContainer.get("v.body");
                            body.push(component);
                            renderingContainer.set("v.body", body);
                        }
                        resolve(component);
                    }
                    else {
                        reject(error);
                    }
                });
            });
        };

        if (renderInto) {
            return new Promise(callback)
                .then(function (component) {
                    return $T.waitFor(function () {
                        if (component.isRendered()) {
                            return component;
                        }
                        return false;
                    });
                });
        } else {
            return new Promise(callback);
        }
    }

    /**
     * Fire an application level event. Takes care of lightning lifecycle related setup needed to successfully interact (e.g. accessChecks) with an application event.
     * @param {string} eventName Name of application event (e.g. c:myAppEvt)
     * @param {Object.<string, Object>} eventArgs The event attributes
     * 
     * @returns {Boolean} A boolean value indicating whether an application level event with specified name was found and fired or not
     */
    $T.fireApplicationEvent = function (eventName, eventArgs) {
        var eventFired = false;
        runInsideCallbackClosure(function () {
            var appEvent = $A.get("e." + eventName);
            if (appEvent) {
                if (eventArgs) {
                    appEvent.setParams(eventArgs);
                }
                appEvent.fire();
                eventFired = true;
            }
        });
        return eventFired;
    }

    /**
     * Clears the components registered to cmpsToCleanup list.
     */
    $T.clearRenderedTestComponents = function () {
        while (cmpsToCleanup.length) {
            var globalId = cmpsToCleanup.shift();
            var cmp = $A.getComponent(globalId);
            cmp.destroy();
        }
    }

    /**
     * @param {function} fn Function to execute inside callback context set by test runner 
     * component via $A.getCallback()
     */
    $T.run = function(fn){
        runInsideCallbackClosure(fn);
    }

    /**
     * [Internal Only] used by test runner component to allow execution of test code within a closure
     */
    $T._setContexualRunner = function (fn) {
        contexualRunner = fn;
    }

    /**
     * [Internal Only] used by test runner component to prepare test results for sfdx extraction.
     */
    $T._sfdxReportForJasmine = function (jasmine) {
        var run_results_full = { "tests": [] };
        var suiteDescription = [];
        var specStartTime = 0;

        var sfdxReporter = {
            suiteStarted: function(suite) {
                suiteDescription.push(suite.description);
            },
            suiteDone: function(suite) {
                suiteDescription.pop();
            },
            specStarted: function(spec) {
                specStartTime = Date.now();
            },
            specDone: function(spec) {
                var fullReport = {};
                var failedStr = '';
                fullReport.FullName =  suiteDescription.join(' : ') + ' : ' + spec.description;
                fullReport.Outcome = 'Pass';
                fullReport.RunTime = Date.now() - specStartTime;

                if ('passed' === spec.status) {
                    console.log('passed!', fullReport.FullName, '- ' + fullReport.RunTime + 'ms');
                } else if ('pending' === spec.status) {
                    console.log('pending!', fullReport.FullName, '- ' + fullReport.RunTime + 'ms');
                    fullReport.Outcome = 'Skip';
                    fullReport.Message = ' # SKIP disabled by xit or similar';
                } else if ('disabled' === spec.status) {
                    console.log('disabled!', fullReport.FullName, '- ' + fullReport.RunTime + 'ms');
                    fullReport.Outcome = 'Disabled';
                } else {
                    console.log('failed!', fullReport.FullName, '- ' + fullReport.RunTime + 'ms');
                    for (var i = 0, failure; i < spec.failedExpectations.length; i++) {
                        var failureMessage = spec.failedExpectations[i].message;
                        failedStr += '\n  ' + failureMessage;
                    }

                    fullReport.Outcome = 'Fail';
                    fullReport.Message = failedStr;
                }
                run_results_full.tests.push(fullReport);
            },
            jasmineDone: function(result) {
                setHiddenDivContent("run_results_full", JSON.stringify(run_results_full));
            }
        };

        jasmine.getEnv().addReporter(sfdxReporter);
    }

    /**
     * [Internal Only] used by test runner component to prepare test results for sfdx extraction.
     */
    $T._sfdxReportForMocha = function (mochaRunner) {
        var run_results_full = { "tests": [] };
        mochaRunner.on('pass', function (test) {
            run_results_full.tests.push(convertMochaTestEventToSfdxTestResult(test));
        }).on('fail', function (test) {
            run_results_full.tests.push(convertMochaTestEventToSfdxTestResult(test));
        }).on('pending', function (test) {
            var pendingTest = Object.assign({}, test, {
                err: {
                    message: ' # SKIP disabled by xit or similar'
                },
                duration: 0,
                state: 'pending'
            });
            run_results_full.tests.push(convertMochaTestEventToSfdxTestResult(pendingTest));
        }).on('end', function (suite) {
            setHiddenDivContent("run_results_full", JSON.stringify(run_results_full));
        });
    }

    /**
     * Turns a mocha test event into a sfdx test result
     */
    var convertMochaTestEventToSfdxTestResult = function (test) {
        console.log(test.state + '!', test.title, '-' + test.duration + 'ms');
        return {
            FullName: generateMochaTestTitleForSfdx(test),
            Outcome: mochaStateToOutcome[test.state],
            RunTime: test.duration,
            Message: test.err ? test.err.message : undefined
        };
    };

    var generateMochaTestTitleForSfdx = function (test) {
        var sfdxTitle = test.title;
        while (!test.parent.root) {
            sfdxTitle = test.parent.title + ' : ' + sfdxTitle;
            test = test.parent;
        }
        return sfdxTitle.replace(/["]/g, "'");
    }

    var mochaStateToOutcome = {
        'passed': 'Pass',
        'failed': 'Failed',
        'pending': 'Skip'
    };

    var setHiddenDivContent = function (id, content) {
        var aDiv = document.getElementById(id);

        if (!aDiv) {
            aDiv = document.createElement("div");
            aDiv.id = id;
            aDiv.style.display = "none";
            document.body.appendChild(aDiv);
        }

        aDiv.innerHTML = content;
        return aDiv;
    };

    /**
     * Runs provided function within a closure to allow interaction with lightning API (e.g. avoid accessCheck errors) 
     * with proper context   
     */
    var runInsideCallbackClosure = function (fn) {
        if (!contexualRunner) {
            throw new Error("callback is not set");
        }
        contexualRunner(fn);
    };
})(this);