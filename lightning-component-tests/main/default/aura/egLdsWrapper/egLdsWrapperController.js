({
    handleCreateRec : function(component, event, helper) {
        var params = event.getParams();
        var worker = component.find("worker");
        component.find("contactRecordCreator").getNewRecord(params.entityApiName,params.recordTypeId,params.defaultFieldValues,params.skipCache, function(){
            worker.createRecordHandler();    
        });
    },

    handleSaveRec : function(component, event, helper) {
        var worker = component.find("worker");
        component.find("contactRecordCreator").saveRecord(function(saveResults){
            worker.saveRecordHandler(saveResults);
        })
    }
})