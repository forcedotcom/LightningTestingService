/**
 * This test suite contains examples that illustrate reusable patterns for testing
 * your custom Lightning components.
 *
 * These tests are written using the [Jasmine framework](https://jasmine.github.io/2.1/introduction).
 * They're run in the Lightning Testing Service using a wrapper, which you can find
 * in jasmineboot.js, in the same repository as this test suite.
 *
 * Note that Jasmine uses "spec" as its name for a test. We use their terminology here
 * for consistency with their documentation.
 */
describe("Lightning Component Testing Examples", function(){
    afterEach(function() {
        // Each spec (test) renders its components into the same div,
        // so we need to clear that div out at the end of each spec.
        $T.clearRenderedTestComponents();
    });

    /**
     * Component under test: 'c:egRenderElement':
     * This spec creates a component, adds it to the body, waits for the rendering to complete,
     * and then ensures that the expected content has been added to the DOM.
     * NOTE: The spec and the component under test are in same locker (same namespace),
     *       so the spec is able to see the DOM owned by the component.
     */
    describe('c:egRenderElement', function(){
        // We encourage you to have the code for c:egRenderElement side by side
        // when reading through this spec.
        it('renders specific static text', function(done) {
            // Define where the component should be rendered during the test.
            // You can update Tests.app to define your own DOM element.
            var renderInto = document.getElementById("renderTestComponents");
            // Instantiate and render the c:egRenderElement Lightning component into the renderInto element.
            // The second parameter (empty here) is the list of component attribute values to set.
            $T.createComponent("c:egRenderElement", {}, renderInto)
            // The 'component' here is the instance of c:egRenderElement
            .then(function(component) {
                expect(document.getElementById("content").textContent).toContain("Hello World!");
                // end this spec successfully
                done();
            }).catch(function(e) {
                // end this spec as a failure
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egComponentMethod'
     * This spec validates that calling a method on the component's public interface
     * causes the expected state change.
     */
    describe('c:egComponentMethod', function() {
        it("updates an attribute value when a method is invoked on the component's interface", function(done) {
            $T.createComponent("c:egComponentMethod", null)
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
     * This spec sets an attribute value, invokes a method, and then validates that
     * the interaction results in expected state and rendering updates.
     */
    describe('c:egClientSideAction', function(){
        it('adds items to a list when the client-side action is invoked', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egClientSideAction", {}, renderInto)
            .then(function(component){
                component.set("v.searchString", "salesforce");
                expect(component.find("accountList").getElement().children.length).toBe(0);
                // Invoke function in component's client-side controller through aura:method
                component.searchAccounts();
                // Assert results of using the component's function (public interface)
                expect(component.get("v.accountList").length).toBe(10);
                expect(component.get("v.accountList")[0]).toContain("salesforce");
                // Assert results by checking DOM element owned by the namespace
                expect(component.find("accountList").getElement().children.length).toBe(10);
                done();

            }).catch(function(e) {
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egServerSideActionCallback'
     * This spec shows how to validate a server-side action end-to-end. The spec interacts with the component
     * to cause a server-side action to be invoked, and then waits for the action callback to update
     * component state as expected.
     * This technique (actually connecting to the server) is discouraged because
     * invoking server actions is time consuming (the spec can timeout), and can have side effects.
     */
    describe('c:egServerSideActionCallback', function(){
        it('[Discouraged: brittle, slow, side-effects] receives server data when server-side action is invoked', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egServerSideActionCallback", {}, renderInto)
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
     * This spec shows how server-side action callbacks can be validated in isolation by exposing the logic of the
     * callback via a component method, and then having the spec use the callback directly for interaction
     */
    describe('c:egServerSideActionCallback', function() {
        it('updates with provided data when action callback is invoked directly', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egServerSideActionCallback", {}, renderInto)
            .then(function(component){
                // Mocking out the server-side action response
                var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"Acct 1"},{"Name":"Acct 2"}];}};
                component.searchAccounts(res);
                // Assert using components interface
                expect(component.get("v.accountList").length).toBe(2);
                expect(component.get("v.accountList")[0]['Name']).toContain("Acct 1");
                // Assert using DOM element owned by the namespace
                expect(component.find("accountList").getElement().children.length).toBe(2);
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egServerSideActionCallback'
     * This spec shows how server-side action callbacks could be validated by mocking the server-side actions using Jasmine spies.
     * This approach relies on Jasmine's mocking capabilities and requires you to construct the server responses yourself.
     * But it eliminates the need for restructuring component production code for testability.
     */
    describe('c:egServerSideActionCallback', function() {
        it('updates with provided data when invoked via a mocked server action using Jasmine spies', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egServerSideActionCallback", {}, renderInto)
            .then(function(component){
                var res = {getState : function(){return "SUCCESS";}, getReturnValue: function(){return [{"Name":"Acct 1"},{"Name":"Acct 2"}];}};
                spyOn($A, "enqueueAction").and.callFake(function(action) {
                    var cb = action.getCallback("SUCCESS")
                    cb.fn.apply(cb.s, [res]);
                });
                component.search();
                // Assert using components interface
                expect(component.get("v.accountList").length).toBe(2);
                expect(component.get("v.accountList")[0]['Name']).toContain("Acct 1");
                // Assert using DOM element owned by the namespace
                expect(component.find("accountList").getElement().children.length).toBe(2);
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });
    });

    /**
     * Component under test: 'c:egAttributeTypes'
     * This spec shows how to interact with various attribute types from a test spec.
     */
    describe('c:egAttributeTypes', function() {
        it('sets component attributes of various types and values', function(done) {
            var attributes = {
                    stringAtr:"string value",
                    integerAtr:20,
                    dateAtr:new Date(),
                    sobjectAtr:{"sObjectType":"Contact", "FirstName":"Marc" , "LastName":"Benioff"},
                    accountAtr:{"sObjectType":"Account", "Name":"salesforce"},
                    objectAtr:{"key1":"value1"}
            };
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egAttributeTypes", attributes, renderInto)
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
     * This spec shows how to interact with facets from a test spec. Note the use of component IDs.
     */
    describe('c:egFacet', function(){
        var attributes = {"content":"textContent"};
        it('renders the expected content when used as a facet', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egFacet", attributes, renderInto)
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
     * This spec shows how to interact with global value providers by programmatically
     * getting a reference to a custom label and validating that its value is being
     * displayed by the component.
     */
    describe('c:egGlobalValueProvider', function(){
        it('renders a custom label', function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.createComponent("c:egGlobalValueProvider", {}, renderInto)
            .then(function(component){
                // You can reference a custom label in your spec using standard
                // Lightning component JavaScript APIs
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
     * This spec shows to validate conditional UI by using the component's interface.
     */
    describe('c:egConditionalUI', function() {
        it('renders only the "truthy" (conditional) portion of the user interface', function(done) {
            $T.createComponent("c:egConditionalUI", null)
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
     * This spec shows how to validate a component's handling of component- and
     * application-level events.
     */
    describe('c:egEventHandling', function() {
        it('handles component- and application-level events', function(done) {
            $T.createComponent("c:egEventHandling", null)
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
});
