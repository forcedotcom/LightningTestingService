({
    handleCreateRec : function(component, event, helper) {
        var params = event.getParams();
        var worker = component.find("worker");
        worker.set("v.newContact", {sobjectType:"Contact"});
        worker.set("v.account", {sobjectType:"Account", id:"XYZ"});
        worker.createRecordHandler();    
    },

    handleSaveRec : function(component, event, helper) {
        var worker = component.find("worker");
        var saveResults = {state:"SUCCESS"};
        worker.saveRecordHandler(saveResults);        
    },

    closeQuickActionFired : function(component, event, helper){
        component.set("v.closeQuickActionFired", true);	    
    }

})