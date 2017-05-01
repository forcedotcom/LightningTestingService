({
    createRecord : function(cmp) {
        var recordDataCreate = cmp.find("recordDataCreate");
        // call getNewRecord of force:recordData
        recordDataCreate.getNewRecord("Account", null, true, function() {
            // once we have  the record template for new record for given entity then update and save the record
            var record = cmp.get('v.recordTemplate');
            record.fields.Name.value = "ADSTestAccount" + (Math.round(Math.random()*10000) + 1);
            record.fields.Industry.value = "Banking";
            record.fields.Type.value = "Prospect";
            recordDataCreate.saveRecord(function(saveResult) {
                if (saveResult.state === 'SUCCESS') {
                    cmp.set("v._recordId", saveResult.recordId);
                    cmp.set('v.fetch', "true"); // this will load the Account record using force:recordData and renders it
                    cmp.set("v.isCallbackCalled", true);
                }
            });
        });
    },

    reloadRecord : function(cmp) {
        cmp.find("recordDataCmp").reloadRecord(false, function(){
            // verify record is reloaded. callback will be called after recordUpdated event is fired
            cmp.set("v.logMessage", cmp.get("v.logMessage") + " After reloadRecord.");
            cmp.set("v.isCallbackCalled", true);
        });
    },

    saveRecord : function(cmp) {
        cmp.set("v.mode", "EDIT");
        var recordDataCmp = cmp.find("recordDataCmp");
        recordDataCmp.reloadRecord(false, function(){
            var record = cmp.get("v.record");
            record.fields.Name.value = "UpdatedRecordName";
            recordDataCmp.saveRecord(function(){
                // verify record is saved. callback will be called after recordUpdated event is fired
                cmp.set("v.logMessage", cmp.get("v.logMessage") + " After saveRecord.");
                cmp.set("v.mode", "VIEW");
                cmp.set("v.isCallbackCalled", true);
            });
        });
    },

    deleteRecord : function(cmp) {
        cmp.find("recordDataCmp").deleteRecord(function(){
            // verify record is deleted. callback will be called after recordUpdated event is fired
            cmp.set("v.logMessage", cmp.get("v.logMessage") + " After deleteRecord.");
            cmp.set('v.fetch', "false");
            cmp.set("v.isCallbackCalled", true);
        });
    }
})