({
    init : function(component, event, helper) {
        component.set("v.objectAtrStringified", JSON.stringify(component.get("v.objectAtr")));
    }
})