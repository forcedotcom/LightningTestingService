({
    runTests : function(component, event, helper) {
        $T._setContexualRunner($A.getCallback(function(callback){callback();}));
        $T._sfdxReportForJasmine(jasmine);
        jasmine.lightningIntegration.execute();
    }
})