/**
 * This suite contains examples to showcase reusable test-patterns
 */
describe("Lightning Component Tests Examples", function(){
    afterEach(function() {
        // Since specs render components in the same div,
        // we want to clear it out at the end of each spec.
        $T.clearRenderedTestComponents();
    });

    /**
     * Component under test: 'c:egRenderElement':
     * This test creates a component, adds it to the body, waits for the rendering to complete 
     * and ensures that the expected content has been added to the DOM
     * NOTE: As the Test and component under test are in same locker (same namespace), test is able to see the DOM owned
     * by the component.
     */
    describe('c:egRenderElement', function(){
        // We encourage you to have the code for c:egRenderElement side by side
        // when reading through this spec.
        it('Creating the component and rendering it shows expected data', function(done) {
            // Defines where the component should be rendered during the test.
            // You can also update Tests.app and define your own DOM element.
            var renderInto = document.getElementById("renderTestComponents");
            // Renders c:egRenderElement Lightning component into the renderInto div.
            // The second param is the list of attributes.
            $T.getComponent("c:egRenderElement", {}, renderInto)
            // The 'component' here is the instance of c:egRenderElement  
            .then(function(component) {
                expect(document.getElementById("content").textContent).toContain("Hello World!");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egComponentMethod'
     * This test validates that calling a method on component's interface causes expected state change.
     */
    describe('c:egComponentMethod', function() {
        it("invoking a method on component's interface updates the attribute value", function(done) {
            $T.getComponent("c:egComponentMethod", null)
            .then(function(component) {
                component.sampleMethod();
                expect(component.get("v.status")).toBe("sampleMethod invoked");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egClientSideAction'
     * This test sets an attribute value, invokes a method and validates that the interaction results
     * in expected state and rendering updates.
     */
    describe('c:egClientSideAction', function(){
        it('invoking client side action via component method populates list in UI', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egClientSideAction", {}, renderInto)
            .then(function(component){
                component.set("v.searchString", "salesforce");
                expect(component.find("accountList").getElement().children.length).toBe(0);
                // Invoke js functions in component's client side controller through aura:method
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

    /**
     * Component under test: 'c:egServerSideActionCallback'
     * This test shows how to validate a server side action end-to-end. The test interacts with the component 
     * to cause a server side action to be invoked, and then then waits for the action callback to update 
     * component state as expected.
     * This is discouraged because invoking the server actions is time consuming (test may timeout) and can have side effects.
     */
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

    /**
     * Component under test: 'c:egServerSideActionCallback'
     * This test shows how server-side action callbacks could be validated in isolation by exposing the logic in
     * callback viq a component method and having the test use it for interaction
     */
    describe('c:egServerSideActionCallback', function() {
        it('invoking action callback directly with success response updates the attributes and UI correctly', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egServerSideActionCallback", {}, renderInto)
            .then(function(component){
                // Mocking out the server side action response 
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

    /**
     * Component under test: 'c:egServerSideActionCallback'
     * This test shows how server side action callbacks could be validated by mocking the server side actions via jasmine spies.
     * This approach relies on jasmine's mocking capabilities and eliminates the need for restructuring component code for testability.
     */
    describe('c:egServerSideActionCallback', function() {
        it('invoking action callback with mocked (jasmine spy) success action response updates the attributes and UI correctly', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egServerSideActionCallback", {}, renderInto)
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

    /**
     * Component under test: 'c:egAttributeTypes'
     * This test shows how to interact with various attribute types from a test spec
     */
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
            $T.getComponent("c:egAttributeTypes", attributes, renderInto)
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

    /**
     * Component under test: 'c:egFacet'
     * This test shows how to interact with facets from a test spec. Note the use of component IDs. 
     */
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

    /**
     * Component under test: 'c:egGlobalValueProvider'
     * This test shows how to interact with global value providers by programmatically getting reference to a 
     * custom label and validating that its value is being displayed by the component
     */
    describe('c:egGlobalValueProvider', function(){
        it('custom label shows up at correct place', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egGlobalValueProvider", {}, renderInto)
            .then(function(component){
                // You can reference custom label from your test
                var greetingLabelVal = $A.get("$Label.c.greeting");
                expect(greetingLabelVal).toBeTruthy(greetingLabelVal);
                expect(component.find("greeting").getElement().textContent).toBe(greetingLabelVal); 
                done();
            }).catch(function(e) {
                done.fail(e);
            }); 
        });
    });

    /**
     * Component under test: 'c:egConditionalUI'
     * This test shows to validate conditional UI by using component's interface
     */
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

    /**
     * Component under test: 'c:egEventHandling'
     * This test shows how to validate component's handling of component and application level events
     */
    describe('c:egEventHandling', function() {
        it('component handles a component and application level event', function(done) {
            $T.getComponent("c:egEventHandling", null)
            .then(function(component){
                var cmpEvent = component.getEvent("sampleEvent");
                cmpEvent.setParams({"data":"component event fired"});
                cmpEvent.fire()
                expect(component.get("v.message")).toBe("component event fired");
                $T.fireApplicationEvent("c:egApplicationEvent", {"data":"application event fired"});
                expect(component.get("v.message")).toBe("application event fired");
                done();
            }).catch(function(e) {
                done.fail(e);
            }); 
        });
    });

    /**
     * Component under test: 'c:egLdsTestWrapper'
     */
    describe('c:egLdsTestWrapper', function(){            
        it('view component (which be used used by a wrapper using Lightning Data Service) works well for success usecase', function(done) {
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