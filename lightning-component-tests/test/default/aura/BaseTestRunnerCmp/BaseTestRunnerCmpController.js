({
	runTests : function(component, event, helper) {
        htmlReporter.initialize();
        jasmine.getEnv().addReporter(new jasmineReporters.Reporter());
    	jasmine.getEnv().execute();
	}
})