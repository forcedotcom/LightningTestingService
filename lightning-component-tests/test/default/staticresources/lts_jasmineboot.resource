/**
 Starting with version 2.0, this file "boots" Jasmine, performing all of the necessary initialization before executing the loaded environment and all of a project's specs. This file should be loaded after `jasmine.js` and `jasmine_html.js`, but before any project source files or spec files are loaded. Thus this file can also be used to customize Jasmine for a project.

 If a project is using Jasmine via the standalone distribution, this file can be customized directly. If a project is using Jasmine via the [Ruby gem][jasmine-gem], this file can be copied into the support directory via `jasmine copy_boot_js`. Other environments (e.g., Python) will have different mechanisms.

 The location of `boot.js` can be specified and/or overridden in `jasmine.yml`.

 [jasmine-gem]: http://github.com/pivotal/jasmine-gem
 */

(function() {

    /**
     * ## Require &amp; Instantiate
     *
     * Require Jasmine's core files. Specifically, this requires and attaches all of Jasmine's code to the `jasmine` reference.
     */
    window.jasmine = jasmineRequire.core(jasmineRequire);

    /**
     * Since this is being run in a browser and the results should populate to an HTML page, require the HTML-specific Jasmine code, injecting the same reference.
     */
    jasmineRequire.html(jasmine);

    /**
     * Create the Jasmine environment. This is used to run all specs in a project.
     */
    var env = jasmine.getEnv();

    /**
     * ## The Global Interface
     *
     * Build up the functions that will be exposed as the Jasmine public interface. A project can customize, rename or alias any of these functions as desired, provided the implementation remains unchanged.
     */
    var jasmineInterface = jasmineRequire.interface(jasmine, env);

    /**
     * Add all of the Jasmine global/public interface to the global scope, so a project can use the public interface directly. For example, calling `describe` in specs instead of `jasmine.getEnv().describe`.
     */
    extend(window, jasmineInterface);

    /**
     * ## Runner Parameters
     *
     * More browser specific code - wrap the query string in an object and to allow for getting/setting parameters from the runner user interface.
     */

    var queryString = new jasmine.QueryString({
        getWindowLocation: function() { return window.location; }
    });

    var catchingExceptions = queryString.getParam("catch");
    env.catchExceptions(typeof catchingExceptions === "undefined" ? true : catchingExceptions);

    var throwingExpectationFailures = queryString.getParam("throwFailures");
    env.throwOnExpectationFailure(throwingExpectationFailures);

    var random = queryString.getParam("random");
    env.randomizeTests(random);

    var seed = queryString.getParam("seed");
    if (seed) {
        env.seed(seed);
    }

    /**
     * ## Reporters
     * The `HtmlReporter` builds all of the HTML UI for the runner page. This reporter paints the dots, stars, and x's for specs, as well as all spec names and all failures (if any).
     */
    var testResultsElementId = 'jasmineHtmlTestResults';
    if(!document.getElementById(testResultsElementId)){
        var resultsDiv = document.createElement("div"); 
        resultsDiv.id = testResultsElementId;
        document.body.appendChild(resultsDiv);
    }
    var htmlReporter = new jasmine.HtmlReporter({
        env: env,
        onRaiseExceptionsClick: function() { queryString.navigateWithNewParam("catch", !env.catchingExceptions()); },
        onThrowExpectationsClick: function() { queryString.navigateWithNewParam("throwFailures", !env.throwingExpectationFailures()); },
        onRandomClick: function() { queryString.navigateWithNewParam("random", !env.randomTests()); },
        addToExistingQueryString: function(key, value) { return queryString.fullStringWithNewParam(key, value); },
        getContainer: function() { return document.getElementById(testResultsElementId); },
        createElement: function() { return document.createElement.apply(document, arguments); },
        createTextNode: function() { return document.createTextNode.apply(document, arguments); },
        timer: new jasmine.Timer()
    });

    /**
     * The `jsApiReporter` also receives spec results, and is used by any environment that needs to extract the results from JavaScript.
     */
    env.addReporter(jasmineInterface.jsApiReporter);
    env.addReporter(htmlReporter);

    /**
     * Filter which specs will be run by matching the start of the full name against the `spec` query param.
     */
    var specFilter = new jasmine.HtmlSpecFilter({
        filterString: function() { return queryString.getParam("spec"); }
    });

    env.specFilter = function(spec) {
        return specFilter.matches(spec.getFullName());
    };



    /**
     * Helper function for readability above.
     */
    function extend(destination, source) {
        for (var property in source) destination[property] = source[property];
        return destination;
    }

    window.jasmine.lightningIntegration = {
            execute : function(){
                htmlReporter.initialize();
                jasmine.getEnv().execute();
            }
    };
}());