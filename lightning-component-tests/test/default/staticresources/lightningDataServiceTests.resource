/**
 * This suite contains tests examples for LDS(Lightning Data Service).
 * Also it demonstrates how to test the component which are doing server side interaction and handling the aura events.
 * Component under these tests: 'c:egLdsView'
 * More details for LDS: https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/data_service.htm
 */
describe('Lightning Data Service Tests Examples (c:egLdsView)', function(){
    var originalTimeout;
    // These tests are doing server side calls and interacting on LDS event, so update the default timeout to reduce tests flappiness.
    var defaultTimeout = 10000;
    beforeEach(function(done) {
        originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
        jasmine.DEFAULT_TIMEOUT_INTERVAL = defaultTimeout;
        
        // Create record in advance for Save, Reload and Delete action in beforeEach function.
        var that = this;
        var renderInto = document.getElementById("renderTestComponents");
        $T.getComponent("c:egLdsView", {}, renderInto)
        .then(function(component){
            that.component = component;
            component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
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
        // Since all the specs renders components in the same div,
        // we want to clear it out and the end of each spec.
        // $T provides test utils.
        $T.clearRenderedTestComponents();
        jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
    });
    
    /**
     * This test validates that force:recordData create method and LDS is notifying component with updated data.
     */
    it('create record', function() {
        // createRecord method in helper is creating record with ADSTestAccount using force:recordData and record will be loaded after save
        expect(this.component.find("accName").get("v.value")).toContain("ADSTestAccount");
        expect(this.component.find("logMessage").get("v.value")).toBe("Record has been loaded.");
    });


    /**
     * Verifying that reload record is loading the record and component is notified with recordUpdated event. 
     */
    it('reload record', function(done) {
        var that = this;
        that.component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
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
     * Verifying that component is notified with new record data when record is being saved with force:recordData.
     */
    it('save record', function(done) {
        var that = this;
        that.component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
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
     * Verifying that component is notified when record is deleted (and removed from cache).
     */
    it('delete record', function(done) {
        var that = this;
        that.component.set("v.isCallbackCalled", false); // callback function in component will set this attribute to true once its called
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
     * Verifying that component is notified with ERROR type and error message when there is an error during CRUD operations with LDS. 
     */
    it('mock recordUpdated for error case', function() {
        var that = this;
        // lightning data service will fire the event with ERROR type when there is an actual error, to test ui behavior mocking the event 
        that.component.find("recordDataCmp").getEvent("recordUpdated").setParams({"changeType":"ERROR"}).fire();
        expect(that.component.find("logMessage").get("v.value")).toBe("There is some error while loading/updating record.");
    });
});