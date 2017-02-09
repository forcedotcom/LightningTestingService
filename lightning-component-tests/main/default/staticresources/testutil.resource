(function (){  
    class $LightningTestUtil{
        static waitFor(fn, timeout, interval) {
            timeout = timeout || 3000;
            interval = interval || 50;
            
            var endTime = new Date().getTime() + timeout;
            return new Promise(function(done, failed) {
                (function poll() {
                    var res = fn();
                    if (res) {
                        done(res);
                    } else if (new Date().getTime() < endTime) {
                        setTimeout(poll, interval);
                    } else {
                        failed(new Error("Timed out after " + timeout
                                         + "ms waiting for: " + fn));
                    }
                })();
            });
        }	
        
        static getComponent(descriptor, attributes) {
            var callback = $A.getCallback(function(done){
                $A.createComponent(descriptor, attributes , function(component){
                    var renderingContainer = $A.getRoot().find("renderTestComponents");
                    var body = renderingContainer.get("v.body");
                    body.push(component);
                    renderingContainer.set("v.body", body);
                    setTimeout(function(){
                        done(component);
                    }, 0);
                });
            });
            return new Promise(callback);
        }
        
        static clearRenderedTestComponents() {
            var callback = $A.getCallback(function(done){
                var renderingContainer = $A.getRoot().find("renderTestComponents");
                renderingContainer.set("v.body", []);
                setTimeout(function(){
                    done();
                }, 0);
            });
            return new Promise(callback);
        }
    }
    window.$LightningTestUtil = $LightningTestUtil;
})();