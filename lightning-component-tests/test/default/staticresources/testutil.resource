(function (global){  

    global.$T = function $T(){};

    var cmpsToCleanup = [];

    /**
     * Waits for the function to finish executing.
     * 
     * @param {function} fn The function to be executed.
     * @param {?number} timeout The total timeout for the wait.
     * @param {?number} interval The interval.
     * @returns {Promise} The wait result.
     */
    $T.waitFor = function(fn, timeout, interval){
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
     * Creates the Lightning component, adds it to the list of components to be cleared,
     * and render it into the specified DOM element.
     * 
     * @param {string} descriptor The descriptor of the component to be rendered.
     * @param {Object.<string, Object>} attributes The attributes to be set to the component.
     * @param {string} renderInto An optional DOM element. If present, newly created component 
     *                            will be pushed in to that elements body.
     * @returns {Promise} component creation or rendering result, depending on whether renderInto is specified
     */
    $T.getComponent = function(descriptor, attributes, renderInto) {
        var callback = $A.getCallback(function(resolve){
            $A.createComponent(descriptor, attributes , function(component) {
                cmpsToCleanup.push(component.getGlobalId());
                if (renderInto) {
                    var renderingContainer = $A.getComponent(renderInto);
                    if (!renderingContainer) {
                        throw new Error("Could not find valid component to render into: " + renderInto);
                    }
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
                return $T.waitFor(function() {
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

    /**
     * Clears the components registered to cmpsToCleanup list.
     */
    // TODO(tbliss): call this automatically at end of test or make test authors add afterEach() block?
    $T.clearRenderedTestComponents = function() {
        while (cmpsToCleanup.length) {
            var globalId = cmpsToCleanup.shift();
            var cmp = $A.getComponent(globalId);
            // TODO(tbliss): destroy removes the DOM and nothing relevant is returned from Component API 
            //               but still lingering references in v.body -- do we care?
            cmp.destroy();
        }
    }
})(this);