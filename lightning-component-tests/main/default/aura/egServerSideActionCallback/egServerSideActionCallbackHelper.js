({
    search : function(cmp) {
        var action = cmp.get("c.searchAccounts");
        this.setupSearchAction(cmp, action);
        $A.enqueueAction(action);
    },
   
    
    setupSearchAction : function(cmp, action){
 	 	action.setParams({ searchString : cmp.get("v.searchString") });          
        action.setCallback(this, function(response){this.handleSearchAccountCallback(cmp, response)});	  
	},
    
    handleSearchAccountCallback : function(cmp, response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				cmp.set("v.accountList", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                $A.log("Action INCOMPLETE");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    $A.log("Unknown error");
                }
            }
        }
})
