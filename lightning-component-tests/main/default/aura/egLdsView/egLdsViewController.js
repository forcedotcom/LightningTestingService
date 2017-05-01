({
    doInit : function(cmp, event, helper){
    },

    createRecord : function(cmp, event, helper) {
        helper.createRecord(cmp);
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
    },

    handleRecordTemplate : function(cmp, event, helper) {
        //handle the recordUpdated event
    },

    /**
     * For testing purpose only (as you cannot get the getElement() of the component for other namespaces)
     */
    clickLightningBtn : function(cmp, event, helper) {
    	var button = event.getParam("btnName");
    	if(button === "create") {
    		helper.createRecord(cmp);
    	} else if(button === "reload") {
    		helper.reloadRecord(cmp);
    	} else if(button === "save") {
    		helper.saveRecord(cmp);
    	} else if(button === "delete") {
    		helper.deleteRecord(cmp);
    	} else {
    		// do nothing
    	}
    }
})