describe("Top Level Suite", function(){    

    afterEach(function() {
    	$T.clearRenderedTestComponents();
    });

	describe('c:egRenderElement', function(){
        it('renders expected data', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egRenderElement", {}, renderInto)
            	.then(function(component) {
                	expect(document.getElementById("content").textContent).toContain("Hello World!");
                	done();
                }).catch(function(e) {
                	done.fail(e);
                });
        });
    });

    describe('c:egClientSideAction', function(){
        it('invoking client side action via component method populates list in UI', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egClientSideAction", {}, renderInto)
            	.then(function(component){
                    component.set("v.searchString", "salesforce");
                    expect(component.find("accountList").getElement().children.length).toBe(0);
                    component.searchAccounts();
                    //Assert using components interface
                    expect(component.get("v.accountList").length).toBe(10);
                    expect(component.get("v.accountList")[0]).toContain("salesforce");
                    //Assert using dom element owned by the namespace
                    expect(component.find("accountList").getElement().children.length).toBe(10);

                    done();
                }).catch(function(e) {
                	done.fail(e);
                });
        });
    });

    describe('c:egServerSideActionCallback', function(){
        it('[Discouraged: brittle, slow, side-effects] invoking server side action end-to-end updates the state correctly.', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egServerSideActionCallback", {}, renderInto)
        		.then(function(component){
        			component.set("v.searchString", "United");
                    expect(component.find("accountList").getElement().children.length).toBe(0);

                    component.search();

                    return $T.waitFor(function(){
                        return component.get("v.accountList").length === 3;
                    })
        		}).then(function() {
                	done();
            	}).catch(function(e) {
                	done.fail(e);
                });  
        });
    });

    describe('c:egServerSideActionCallback', function() {
        it('invoking action callback with success response updates the attributes and UI correctly', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
        	$T.getComponent("c:egServerSideActionCallback", {}, renderInto)
        		.then(function(component){
                    var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"Acct 1"},{"Name":"Acct 2"}];}}; 
                    component.searchAccounts(res);

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

    describe('c:egAttributeTypes', function() {
        it('setting component attributes of various types and validating values', function(done) {
            var attributes = {
            		stringAtr:"string value", 
                    integerAtr:20, 
                    dateAtr:new Date(),
                    sobjectAtr:{"sObjectType":"Contact", "FirstName":"Marc" , "LastName":"Benioff"},
                    accountAtr:{"sObjectType":"Account", "Name":"salesforce"},
                    objectAtr:{"key1":"value1"}
            };
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egAttributeTypes",attributes, renderInto)
            .then(function(component){
                expect(component.find("stringAtrAuraId").getElement().innerHTML).toContain(attributes.stringAtr);
                expect(component.get("v.integerAtr")).toBe(attributes.integerAtr);
                expect(component.get("v.objectAtrStringified")).toBe(JSON.stringify(attributes.objectAtr));
                done();
            }).catch(function(e) {
            	done.fail(e);
            });
        });
    });

    describe('c:egFacet', function(){    
        var attributes = {"content":"textContent"};
        it('setting a component facet and validating the output', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egFacet", attributes, renderInto)
	            .then(function(component){
	                expect(component.find("cmpUnderTest").find("AuraComponentAtrId").getElement().innerHTML).toContain(attributes.content);
	                done();
	            }).catch(function(e) {
                	done.fail(e);
                }); 
        });
    });

    describe('c:egGlobalValueProvider', function(){
        it('custom label shows up at correct place', function(done) {
        	var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egGlobalValueProvider", {}, renderInto)
            .then(function(component){
                var greetingLabelVal = $A.get("$Label.c.greeting");
                expect(greetingLabelVal).toBeTruthy(greetingLabelVal);
                expect(component.find("greeting").getElement().textContent).toBe(greetingLabelVal); 
                done();
            }).catch(function(e) {
            	done.fail(e);
            }); 
        });
    });

    describe('c:egConditionalUI', function() {        
        it('component renders only the portion of UI based on a conditional', function(done) {
            $T.getComponent("c:egConditionalUI", null)
	            .then(function(component) {
	                expect(component.find("trueDiv")).toBeTruthy(); 
	                expect(component.find("falseDiv")).toBeFalsy();    
	                component.find("toggleButton").getEvent("press").fire();
	                expect(component.find("trueDiv")).toBeFalsy(); 
	                expect(component.find("falseDiv")).toBeTruthy();                 
	                done();
	            }).catch(function(e) {
                	done.fail(e);
                }); 
        });
    });

    describe('c:egEventHandling', function() {           
        it('component handles a component and application level event', function(done) {
            $T.getComponent("c:egEventHandling", null)
            .then(function(component){
                var cmpEvent = component.getEvent("sampleEvent");
                cmpEvent.setParams({"data":"component event fired"});
                cmpEvent.fire()
                expect(component.get("v.message")).toBe("component event fired");

                var appEvent = $A.get("e.c:egApplicationEvent");
                appEvent.setParams({"data":"application event fired"});
                appEvent.fire()
                expect(component.get("v.message")).toBe("application event fired");
                done();
            }).catch(function(e) {
            	done.fail(e);
            }); 
        });
    });

    describe('c:egLdsTestWrapper', function(){            
        it('view component (which be used used by a wrapper using LDS) works well for success usecase', function(done) {
            $T.getComponent("c:egLdsTestWrapper", null)
            .then(function(component){
                component.find("worker").find("contactFirstName").set("v.value", "John");
                component.find("worker").find("contactLastName").set("v.value", "Doe");
                component.find("worker").find("saveContact").get("e.press").fire()
                expect(component.get("v.closeQuickActionFired")).toBe(true);
                done();
            }).catch(function(e) {
            	done.fail(e);
            }); 
        });
    });
});
