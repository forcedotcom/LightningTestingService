describe("Top Level Suite", function(){
    describe("Sample: Passing", function() {
        it("A simple passing tests", function() {
            expect(true).toBe(true);
        });
    });
         
    describe("Sample: Failing", function() {
        it("A simple failing test", function() {
            expect(true).toBe(false);
        });
    });
    
    describe('c:cmpUnderTest2', function(){
        it('Rendering components shows expected data', function(done) {
            $LightningTestUtil.getComponent("c:cmpUnderTest2", null).then(
                function(component){
                    $LightningTestUtil.waitFor(function(){
                        return document.getElementById("content") != null
                    }).then(function(){
                        expect(document.getElementById("content").textContent).toContain("Hello World!");
                        done();
                    });
                });   
        });
    });
    
     describe('c:cmpUnderTest3', function(){
        it('Validate invoking Search Action Populates Account List', function(done) {
            $LightningTestUtil.getComponent("c:cmpUnderTest3", null).then(
                function(component){
                    $LightningTestUtil.waitFor(function(){
                        return document.getElementById("content") != null
                    }).then(function(){
                        debugger;
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
    
    afterEach(function(done){
        $LightningTestUtil.clearRenderedTestComponents().then(function(){done();});
    });
});