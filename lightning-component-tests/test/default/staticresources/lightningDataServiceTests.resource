describe('c:egLdsView (Lightning Data Service)', function(){
    var originalTimeout;
    beforeEach(function() {
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
    
    it('create the record using force:recordData', function(done) {
    	var renderInto = document.getElementById("renderTestComponents");
        $T.getComponent("c:egLdsView", {}, renderInto)
        .then(function(component){
        	this.component = component;
        	component.set("v.isCallbackCalled", false); // callback function in component will set it to true once its called
            var ldsClickEvent = $A.get("e.c:egLdsClickEvent");
            ldsClickEvent.setParams({"btnName":"create"});
            ldsClickEvent.fire();
            return $T.waitFor(function(){
                return component.get("v.isCallbackCalled") === true && component.get("v.record") != null;
            }, 10000);
		}).then(function() {
        	expect(component.get("v.record").fields.Name.value).toContain("ADSTestAccount");
    		expect(component.get("v.logMessage")).toBe("Record has been loaded.");
			done();
    	}).catch(function(e) {
        	done.fail(e);
    	});
    });
    
    describe('Reload, Save and Delete record - ', function(){
    	beforeEach(function(done) {
    		var renderInto = document.getElementById("renderTestComponents");
    		$T.getComponent("c:egLdsView", {}, renderInto)
    		.then(function(component){
    			this.component = component;
    			component.set("v.isCallbackCalled", false); // callback function in component will set it to true once its called
    			// create record in advance for Save, Reload and Delete action in beforeEach function
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
 	
        it('reload record', function(done) {
        	component.set("v.isCallbackCalled", false); // callback function in component will set it to true once its called
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
        
        it('save record', function(done) {
        	component.set("v.isCallbackCalled", false); // callback function in component will set it to true once its called
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
        
        it('delete record', function(done) {
        	component.set("v.isCallbackCalled", false); // callback function in component will set it to true once its called
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
        
        it('mock recordUpdated for error case', function() {
        	// lightning data service will fire the event with ERROR type when there is an actual error, to test ui behavior mocking the event 
        	component.find("recordDataCmp").getEvent("recordUpdated").setParams({"changeType":"ERROR"}).fire();
    		expect(component.get("v.logMessage")).toBe("There is some error while loading/updating record.");
        });
        
    }); //end describe-Reload, Save and Delete record
});