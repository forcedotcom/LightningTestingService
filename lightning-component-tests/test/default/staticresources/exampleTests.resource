describe("Top Level Suite", function(){    

	describe('c:egRenderElement', function(){
        it('renders expected data', function(done) {
            $LightningTestUtil.getComponent("c:egRenderElement", {}, "renderTestComponents")
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
            $LightningTestUtil.getComponent("c:egClientSideAction", {}, "renderTestComponents").then(
                    function(component){
                        $LightningTestUtil.waitFor(function(){
                            return document.getElementById("content") !== null
                        }).then(function(){
                            component.set("v.searchString", "salesforce");
                            expect(component.find("accountList").getElement().children.length).toBe(0);
                            component.searchAccounts();
                            //Assert using components interface
                            expect(component.get("v.accountList").length).toBe(10);
                            expect(component.get("v.accountList")[0]).toContain("salesforce");
                            //Assert using dom element owned by the namespace
                            expect(component.find("accountList").getElement().children.length).toBe(10);

                            done();
                        });
                    });   
        });
    });

    describe('c:egServerSideActionCallback', function(){
        it('invoking action callback with success response updates the attributes and UI correctly', function(done) {
            $LightningTestUtil.getComponent("c:egServerSideActionCallback", {}, "renderTestComponents").then(
                    function(component){
                        $LightningTestUtil.waitFor(function(){
                            return document.getElementById("content") != null
                        }).then(function(){
                            component.set("v.searchString", "United");
                            expect(component.find("accountList").getElement().children.length).toBe(0);

                            component.search();


                        }).then(function(){
                            $LightningTestUtil.waitFor(function(){
                                return component.get("v.accountList").length === 3;
                            }).then(function(){done();})});
                    });   
        });
    });

    describe('c:egServerSideActionCallback', function(){
        it('[Discouraged: brittle, slow, side-effects] invoking server side action end-to-end updates the state correctly.', function(done) {
            $LightningTestUtil.getComponent("c:egServerSideActionCallback", {}, "renderTestComponents").then(
                    function(component){
                        $LightningTestUtil.waitFor(function(){
                            return document.getElementById("content") != null
                        }).then(function(){

                            var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"emad"},{"Name":"salman"}];}}; 
                            component.searchAccounts(res);

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

    describe('c:egAttributeTypes', function(){    	 		    
        it('setting component attributes of various types and validating values', function(done) {
            var attributes = {stringAtr:"string value", 
                    integerAtr:20, 
                    dateAtr:new Date(),
                    sobjectAtr:{"sObjectType":"Contact", "FirstName":"Marc" , "LastName":"Benioff"},
                    accountAtr:{"sObjectType":"Account", "Name":"salesforce"},
                    objectAtr:{"key1":"value1"},

            };
            $LightningTestUtil.getComponent("c:egAttributeTypes",attributes, "renderTestComponents")
            .then(function(component){
                expect(component.find("stringAtrAuraId").getElement().innerHTML).toContain(attributes.stringAtr);
                expect(component.get("v.integerAtr")).toBe(attributes.integerAtr);
                expect(component.get("v.objectAtrStringified")).toBe(JSON.stringify(attributes.objectAtr));
                done();
            });
        });
    });

    describe('c:egFacet', function(){    
        var attributes = {"content":"textContent"};
        it('setting a component facet and validating the output', function(done) {
            $LightningTestUtil.getComponent("c:egFacet", attributes, "renderTestComponents")
            .then(function(component){

                expect(component.find("cmpUnderTest").find("AuraComponentAtrId").getElement().innerHTML).toContain(attributes.content) ;

                done();
            });
        });
    });

    describe('c:egGlobalValueProvider', function(){            
        it('custom label shows up at correct place', function(done) {
            $LightningTestUtil.getComponent("c:egGlobalValueProvider", {}, "renderTestComponents")
            .then(function(component){
                var greetingLabelVal = $A.get("$Label.c.greeting");
                expect(greetingLabelVal).toBeTruthy(greetingLabelVal);
                expect(component.find("greeting").getElement().textContent).toBe(greetingLabelVal); 
                done();
            });
        });
    });

    describe('c:egConditionalUI', function(){            
        it('component renders only the portion of UI based on a conditional', function(done) {
            $LightningTestUtil.getComponent("c:egConditionalUI", null)
            .then(function(component){
                expect(component.find("trueDiv")).toBeTruthy(); 
                expect(component.find("falseDiv")).toBeFalsy();    
                component.find("toggleButton").getEvent("press").fire();
                expect(component.find("trueDiv")).toBeFalsy(); 
                expect(component.find("falseDiv")).toBeTruthy();                 
                done();
            });
        });
    });

    describe('c:egEventHandling', function(){            
        it('component handles a component and application level event', function(done) {
            $LightningTestUtil.getComponent("c:egEventHandling", null)
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
            });
        });
    });

    describe('c:egLdsTestWrapper', function(){            
        it('view component (which be used used by a wrapper using LDS) works well for success usecase', function(done) {
            $LightningTestUtil.getComponent("c:egLdsTestWrapper", null)
            .then(function(component){
                debugger;
                component.find("worker").find("contactFirstName").set("v.value", "John");
                component.find("worker").find("contactLastName").set("v.value", "Doe");
                component.find("worker").find("saveContact").get("e.press").fire()
                expect(component.get("v.closeQuickActionFired")).toBe(true);
                done();
            });
        });
    });

    afterEach(function(done){
        $LightningTestUtil.clearRenderedTestComponents().then(function(){done();});
    });
});
