({
	search : function(component, event, helper) {
		//var searchString = component.get("v.searchString");
       helper.search(component);
	},
    
    searchCallback : function(component, event, helper) {
       helper.handleSearchAccountCallback(component, event.getParam('arguments').response);        
	}   
})