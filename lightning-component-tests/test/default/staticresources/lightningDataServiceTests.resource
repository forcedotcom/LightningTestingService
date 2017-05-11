/**
 * This suite contains tests examples for LDS(Lightning Data Service).
 * Also it demonstrates how to test the component which are doing server side interaction and handling the aura events.
 * Component under these tests: 'c:egLdsView'
 * More details for LDS: https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/data_service.htm
 */
describe('Lightning Data Service Tests Examples (c:egLdsView)', function(){
    var originalTimeout;
    beforeEach(function() {
        // These tests are doing server side calls and interacting on LDS event, so update the default timeout to reduce tests flappiness.
        originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;
    });
    afterEach(function() {
        // Since all the specs renders components in the same div,
        // we want to clear it out and the end of each spec.
        // $T provides test utils.
        $T.clearRenderedTestComponents();
        jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
    });
    
    /**
     * This test validates that force:recordData create method and LDS is notifying component with updated data.   
     */
    it('create the record using force:recordData', function(done) {
        var renderInto = document.getElementById("renderTestComponents");
        $T.getComponent("c:egLdsView", {}, renderInto)
        .then(function(component){
            this.component = component;
            component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
            var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
            ldsClickEvent.setParams({"btnName":"create"});
            ldsClickEvent.fire();
            return $T.waitFor(function(){
                return component.get("v.isCallbackCalled") === true && component.get("v.record") != null;
            }, 10000);
        }).then(function() {
            // createRecord method in helper is creating record with ADSTestAccount using force:recordData and record will be loaded after save
            expect(component.get("v.record").fields.Name.value).toContain("ADSTestAccount");
            expect(component.get("v.logMessage")).toBe("Record has been loaded.");
            done();
        }).catch(function(e) {
            done.fail(e);
        });
    });

    /**
     * These tests are for Reload, Save and Delete methods of force:recordData.
     */
    describe('Reload, Save and Delete record using force:recordData', function(){
        beforeEach(function(done) {
            var renderInto = document.getElementById("renderTestComponents");
            $T.getComponent("c:egLdsView", {}, renderInto)
            .then(function(component){
                this.component = component;
                component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
                // Create record in advance for Save, Reload and Delete action in beforeEach function.
                var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
                ldsClickEvent.setParams({"btnName":"create"});
                ldsClickEvent.fire();
                return $T.waitFor(function(){
                    return component.get("v.isCallbackCalled") === true;
                }, 7000);
            }).then(function() {
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * Verifying that reload record is loading the record and component is notified with recordUpdated event. 
         */
        it('reload record', function(done) {
            component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
            var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
            ldsClickEvent.setParams({"btnName":"reload"});
            ldsClickEvent.fire();
            return $T.waitFor(function(){
                return component.get("v.isCallbackCalled") === true;
            }, 7000).then(function() {
                expect(component.get("v.logMessage")).toBe("Record has been loaded. After reloadRecord.");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * Verifying that component is notified with new record data when record is being saved with force:recordData.
         */
        it('save record', function(done) {
            component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
            var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
            ldsClickEvent.setParams({"btnName":"save"});
            ldsClickEvent.fire();
            return $T.waitFor(function(){
                return component.get("v.isCallbackCalled") === true;
            }, 7000).then(function() {
                expect(component.get("v.record").fields.Name.value).toEqual("UpdatedRecordName");
                expect(component.get("v.logMessage")).toBe("Record has been changed. After saveRecord.");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * Verifying that component is notified when record is deleted (and removed from cache).
         */
        it('delete record', function(done) {
            component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
            var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
            ldsClickEvent.setParams({"btnName":"delete"});
            ldsClickEvent.fire();
            return $T.waitFor(function(){
                return component.get("v.isCallbackCalled") === true;
            }, 7000).then(function() {
                expect(component.get("v.logMessage")).toBe("Record has been removed. After deleteRecord.");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * Verifying that component is notified with ERROR type and error message when there is an error during CRUD operations with LDS. 
         */
        it('mock recordUpdated for error case', function() {
            // lightning data service will fire the event with ERROR type when there is an actual error, to test ui behavior mocking the event 
            component.find("recordDataCmp").getEvent("recordUpdated").setParams({"changeType":"ERROR"}).fire();
            expect(component.get("v.logMessage")).toBe("There is some error while loading/updating record.");
        });

    }); //end describe-Reload, Save and Delete record
});