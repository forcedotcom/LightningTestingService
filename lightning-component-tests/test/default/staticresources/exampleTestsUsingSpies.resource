describe("Top Level Suite", function(){
    afterEach(function() {
        $LightningTestUtil.clearRenderedTestComponents();
    });

    describe('c:egServerSideActionCallback', function() {
        it('spy example: invoking action callback with success response updates the attributes and UI correctly', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $LightningTestUtil.getComponent("c:egServerSideActionCallback", {}, renderInto)
                .then(function(component){
                    var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"Acct 1"},{"Name":"Acct 2"}];}}; 
                    spyOn($A, "enqueueAction").and.callFake(function(action) {
                        var cb = action.getCallback("SUCCESS")
                        cb.fn.apply(cb.s, [res]);
                    });

                    component.search();

                    //Assert using components interface
                    expect(component.get("v.accountList").length).toBe(2);
                    expect(component.get("v.accountList")[0]['Name']).toContain("Acct 1");
                    //Assert using dom element owned by the namespace
                    expect(component.find("accountList").getElement().children.length).toBe(2);

                    done();
                }).catch(function(e) {
                    done.fail(e);
                });          
        });
    });
    
    /*
    describe('c:egServerSideActionCallback', function(){
        it('spy example: invoking action callback with success response updates the attributes and UI correctly', function(done) {
            $LightningTestUtil.getComponent("c:egServerSideActionCallback", null).then(
                    function(component){
                        $LightningTestUtil.waitFor(function(){
                            return document.getElementById("content") != null
                        }).then(function(){
                            var c, fn;
                            var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"emad"},{"Name":"salman"}];}}; 

                            //Ideally may be when can get by with just spying on $A.enqueueAction but
                            //the action passed to it doesn't seem to provide access to the callback.
                            var actionSpy = spyOn(component, "get");
                            var getOveride =  function(name) {
                                if(name === "c.searchAccounts"){
                                    var action = {
                                            setParams:function(){},
                                            setCallback:function(scope, callback){fn = callback; c = scope;}
                                    };                                  
                                    return action;
                                }
                                else{
                                    //TODO find a better way
                                    //somewhat round about way to conditionally call the original function 
                                    //courtesy: http://stackoverflow.com/questions/27398525/can-i-call-the-original-method-inside-the-supplied-function-to-andcallfake-of
                                    actionSpy.and.callThrough();
                                    try{
                                        var returnVal = component.get(name); 
                                    }
                                    finally{
                                        actionSpy.and.callFake(getOveride);
                                    }
                                    return returnVal;
                                }
                            };
                            actionSpy.and.callFake(getOveride);

                            spyOn($A, "enqueueAction").and.callFake(function(action) {
                                fn.apply(c, [res]);
                            });

                            component.search();

                            //Assert using components interface
                            expect(component.get("v.accountList").length).toBe(2);
                            expect(component.get("v.accountList")[0]['Name']).toContain("emad");
                            //Assert using dom element owned by the namespace
                            expect(component.find("accountList").getElement().children.length).toBe(2);

                            done();
                        });
                    });           
        });
    });
    */
});