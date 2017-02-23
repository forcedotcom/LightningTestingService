({
    doInit: function(component, event, helper) {
        var e = component.get("e.createrec");//TODO
        e.setParams({"entityApiName":"Contact", "recordTypeId":null, "defaultFieldValues":null, "skipCache":false});
        e.fire();
    },

    createRecordHandler: function(component, event, helper){
        var rec = component.get("v.newContact");
        var error = component.get("v.newContactError");
        if(error || (rec === null)) {
            console.log("Error initializing record template: " + error);
        }
        else {
            console.log("Record template initialized: " + rec.sobjectType);
        }
    },

    handleSaveContact: function(component, event, helper) {
        if(helper.validateContactForm(component)) {
            component.set("v.hasErrors", false);
            component.set("v.newContact.AccountId", component.get("v.recordId"));
            component.get("e.saverec").fire();//TODO
        }
        else {
            // New contact form failed validation, show a message to review errors
            component.set("v.hasErrors", true);
        }
    },

    saveRecordHandler: function(component, event, helper){
        var saveResult = event.getParam("arguments").saveResult; 
        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {

            // Success! Prepare a toast UI message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Contact Saved",
                "message": "The new contact was created."
            });

            // Update the UI: close panel, show toast, refresh account page
            $A.get("e.force:closeQuickAction").fire();
            resultsToast.fire();

            // Reload the view so components not using force:recordPreview
            // are updated
            $A.get("e.force:refreshView").fire();
        }
        else if (saveResult.state === "INCOMPLETE") {
            console.log("User is offline, device doesn't support drafts.");
        }
        else if (saveResult.state === "ERROR") {
            console.log('Problem saving contact, error: ' +
                    JSON.stringify(saveResult.error));
        }
        else {
            console.log('Unknown problem, state: ' + saveResult.state +
                    ', error: ' + JSON.stringify(saveResult.error));
        }

    },

    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})