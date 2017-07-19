/**
 * This test suite contains examples that illustrate testing custom Lightning
 * components that use
 * [Lightning Data Service](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/data_service.htm)
 * (LDS).
 *
 * It also demonstrates how to test components with server-side interaction, and
 * handling Lightning component events.
 *
 * Component under these tests: 'c:egLdsView'
 *
 */
describe('The Lightning Data Service Examples', function(){

    describe('c:egLdsView', function(){
        // These tests are making server-side calls and interacting with LDS events,
        // so increase the default timeout to reduce tests flappiness
        var originalTimeout;
        var defaultTimeout = 10000;

        beforeEach(function(done) {
            originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
            jasmine.DEFAULT_TIMEOUT_INTERVAL = defaultTimeout;

            // Create a record in advance, for use with the Save, Reload and Delete actions
            var that = this;
            $T.createComponent("c:egLdsView", {}, true)
            .then(function(component){
                that.component = component;
                component.set("v.isCallbackCalled", false); // the callback function will set this to true once it's called
                component.getNewRecord();
                return $T.waitFor(function(){
                    return component.get("v.isCallbackCalled") === true && component.get("v.record") != null;
                }, defaultTimeout);
            }).then(function() {
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        afterEach(function() {
            // Each spec (test) renders its components into the same div,
            // so we need to clear that div out at the end of each spec.
            $T.clearRenderedTestComponents();
            jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
        });

        /**
         * This test checks that the force:recordData create method works, and that LDS
         * is notifying our component with the added/updated data.
         */
        it('updates the component and loads record data when a record is created', function() {
            // createRecord method in helper is creating record with ADSTestAccount
            // using force:recordData; the record should be loaded after save
            expect(this.component.find("accName").get("v.value")).toContain("ADSTestAccount");
            expect(this.component.find("logMessage").get("v.value")).toBe("Record has been loaded.");
        });


        /**
         * This test checks that reload record is loading the record and that the
         * component is notified using the recordUpdated event.
         */
        it('loads a record and logs a success message when a record is reloaded', function(done) {
            var that = this;
            that.component.set("v.isCallbackCalled", false); // the callback function will set this to true once it's called
            that.component.reloadRecord();
            return $T.waitFor(function(){
                return that.component.get("v.isCallbackCalled") === true;
            }, defaultTimeout).then(function() {
                expect(that.component.find("logMessage").get("v.value")).toBe("Record has been loaded.");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * This test checks that the component is notified with new record data when the
         * record is saved with force:recordData.
         */
        it('updates data held in the client-side component when a record is saved', function(done) {
            var that = this;
            that.component.set("v.isCallbackCalled", false); // the callback function will set this to true once it's called
            // load the record in edit mode, change the value and save the record
            that.component.set("v.mode", "EDIT");
            that.component.reloadRecord();
            return $T.waitFor(function(){
                return that.component.get("v.isCallbackCalled") === true;
            }, defaultTimeout).then(function(){
                // update the record value
                var record = that.component.get("v.record");
                record.fields.Name.value = "UpdatedRecordNameFromTest";
                that.component.set("v.isCallbackCalled", false);
                that.component.saveRecord();
                return $T.waitFor(function(){
                    return that.component.get("v.isCallbackCalled") === true;
                }, defaultTimeout).then(function() {
                    expect(that.component.find("accName").get("v.value")).toBe("UpdatedRecordNameFromTest");
                    done();
                }).catch(function(e) {
                    done.fail(e);
                });
            }).catch(function(e) {
                done.fail(e);
            });;

        });

        /**
         * This test checks that the component is notified when the record is deleted
         * (and removed from cache).
         */
        it('updates the component with a message when a record is deleted', function(done) {
            var that = this;
            that.component.set("v.isCallbackCalled", false); // the callback function will set this to true once it's called
            that.component.deleteRecord();
            return $T.waitFor(function(){
                return that.component.get("v.isCallbackCalled") === true;
            }, defaultTimeout).then(function() {
                expect(that.component.find("logMessage").get("v.value")).toBe("Record has been removed.");
                done();
            }).catch(function(e) {
                done.fail(e);
            });
        });

        /**
         * This test checks that the component is notified with a change notification of
         * type ERROR, with the expected error message, when there is an error during
         * CRUD operations with LDS.
         */
        it('handles errors with a message when there\'s an error with data access', function() {
            var that = this;
            // LDS fires an event with ERROR type when there's an actual error
            // This tests UI behavior by mocking the event
            that.component.find("recordDataCmp").getEvent("recordUpdated").setParams({"changeType":"ERROR"}).fire();
            expect(that.component.find("logMessage").get("v.value")).toBe("There is some error while loading/updating record.");
        });
    });
});
