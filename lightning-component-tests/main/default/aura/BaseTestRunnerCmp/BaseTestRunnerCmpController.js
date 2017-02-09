({
	runTests : function(component, event, helper) {
        htmlReporter.initialize();
        jasmine.getEnv().addReporter(new jasmineReporters.TapReporter());
    	jasmine.getEnv().execute();
	}
})