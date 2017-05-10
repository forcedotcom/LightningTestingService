({
    search : function(component, event, helper) {
        var searchString = component.get("v.searchString");
        component.set("v.accountList", helper.search(searchString));
    }
})