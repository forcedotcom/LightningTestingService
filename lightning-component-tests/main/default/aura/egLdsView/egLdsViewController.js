({
    getNewRecord : function(cmp, event, helper) {
        helper.getNewRecord(cmp);
    },

    reloadRecord : function(cmp, event, helper) {
        helper.reloadRecord(cmp);
    },

    saveRecord : function(cmp, event, helper) {
        helper.saveRecord(cmp);
    },

    deleteRecord : function(cmp, event, helper) {
        helper.deleteRecord(cmp);
    },

    handleRecordUpdate : function(cmp, event) {
        //handle the recordUpdated event
        var changeType = event.getParam("changeType");
        if(changeType === "LOADED") {
            // handle record loaded
            cmp.set("v.logMessage", "Record has been loaded.");
        } else if(changeType === "CHANGED") {
            // handle record changed
            cmp.set("v.logMessage", "Record has been changed.");
        } else if(changeType === "REMOVED") {
            // handle record removed
            cmp.set("v.logMessage", "Record has been removed.");
        } else if(changeType === "ERROR") {
            // handle error while loading|saving|deleting record
            cmp.set("v.logMessage", "There is some error while loading/updating record.");
        } else {
            // you should not get any other type than these 4 (as of Summer '17)
        }
    }
})