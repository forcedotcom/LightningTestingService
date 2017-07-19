({
    runTests : function(component, event, helper) {
        $T._setContexualRunner($A.getCallback(function(callback){callback();}));
        jasmine.lightningIntegration.execute();
    }
})