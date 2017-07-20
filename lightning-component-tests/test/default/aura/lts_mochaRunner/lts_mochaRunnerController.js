({
    runTests: function (component, event, helper) {
        $T._setContexualRunner($A.getCallback(function (callback) { callback(); }));
        var mochaRunner = mocha.run();        
        $T._sfdxReportForMocha(mochaRunner);
    }
})