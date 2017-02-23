(function (global){  
    global.$LightningTestUtil = function $LightningTestUtil(){};

    $LightningTestUtil.waitFor = function(fn, timeout, interval){
        timeout = timeout || 3000;
        interval = interval || 50;

        var endTime = new Date().getTime() + timeout;
        return new Promise(function(resolve, reject) {
            (function poll() {
            	debugger;
                var res = fn();
                if (res) {
                    resolve(res);
                } else if (new Date().getTime() < endTime) {
                    setTimeout(poll, interval);
                } else {
                    reject(new Error("Timed out after " + timeout
                            + "ms waiting for: " + fn));
                }
            })();
        });
    }

    $LightningTestUtil.getComponent = function(descriptor, attributes, renderInto) {
        var callback = $A.getCallback(function(resolve){
            $A.createComponent(descriptor, attributes , function(component) {
            	if (renderInto) {
            		var el = document.getElementById(renderInto);
            		if (!el) {
            			throw new Error("Could not find element with id [" + renderInto + "] to render component " + descriptor + "] into");
            		}
            		var renderingContainer = $A.getComponent(el);
                    var body = renderingContainer.get("v.body");
                    body.push(component);
                    renderingContainer.set("v.body", body);
            	}

            	resolve(component);
            });
        });

        if (renderInto) {
        	return new Promise(callback)
        		.then(function(component) {
	        		// TODO(tbliss): better way to wait and still return component when done?
	        		return $LightningTestUtil.waitFor(function() {
	        			if(component.isRendered()) {
	        				return component;
	        			}
	        			return false;
	        		});
        		});
        } else {
        	return new Promise(callback);
        }
    }

    $LightningTestUtil.clearRenderedTestComponents = function() {
        var callback = $A.getCallback(function(resolve){
            var renderingContainer = $A.getRoot().find("renderTestComponents");
            // TODO(tbliss): this forces original container to be empty otherwise we mess with tree by clearing
            renderingContainer.set("v.body", []);
            setTimeout(function(){
                resolve();
            }, 0);
        });
        return new Promise(callback);
    }
})(this);