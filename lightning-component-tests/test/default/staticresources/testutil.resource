(function (global){  
    global.$LightningTestUtil = function $LightningTestUtil(){};

    var cmpsToCleanup = [];

    $LightningTestUtil.waitFor = function(fn, timeout, interval){
        timeout = timeout || 3000;
        interval = interval || 50;

        var endTime = new Date().getTime() + timeout;
        return new Promise(function(resolve, reject) {
            (function poll() {
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

    /**
     * renderInto is optional and can be a DOM element or Aura component. If present, newly created component will be
     * pushed in to that components body.
     */
    $LightningTestUtil.getComponent = function(descriptor, attributes, renderInto) {
        var callback = $A.getCallback(function(resolve){
            $A.createComponent(descriptor, attributes , function(component) {
            	cmpsToCleanup.push(component.getGlobalId());
            	if (renderInto) {
            		var renderingContainer = renderInto;
            		// TODO(tbliss): need better way to do type detection. for now just assume it's a DOM element
//            		if (renderingContainer instanceof HTMLElement) {
            			renderingContainer = $A.getComponent(renderInto);
//            		} else if (!(renderingContainer.getElements && renderingContainer.getGlobalId)) {
            			// not a DOM element or Aura component
//            			throw new Error("Could not find valid component to render into: " + renderInto);
//            		}
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

    // TODO(tbliss): call this automatically at end of test or make test authors add afterEach() block?
    $LightningTestUtil.clearRenderedTestComponents = function() {
    	while (cmpsToCleanup.length) {
    		var globalId = cmpsToCleanup.shift();
    		var cmp = $A.getComponent(globalId);
    		// TODO(tbliss): destroy removes the DOM and nothing relevant is returned from Component API 
    		//               but still lingering references in v.body -- do we care?
    		cmp.destroy();
    	}
    }
})(this);