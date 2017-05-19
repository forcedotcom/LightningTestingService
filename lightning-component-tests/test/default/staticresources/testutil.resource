/**
 * This test util aims to reduce the boiler plate code needed in the test specs by providing helper methods for common test patterns.
 * Tests reference the helper methods via '$T'.
 */
(function (global){  
    global.$T = function $T(){};

    var cmpsToCleanup = [];
    var contexualRunner;

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
    $T.createComponent = function(descriptor, attributes, renderInto) {
        var callback = function(resolve, reject){
            runInsideCallbackClosure(function(){
                $A.createComponent(descriptor, attributes , function(component, status, error) {
                    if(status === "SUCCESS"){
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
                    }
                    else{
                        reject(error);
                    }
                });
            });
        };

        if (renderInto) {
            return new Promise(callback)
            .then(function(component) {
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
     * Fire an application level event. Takes care of lightning lifecycle related setup needed to successfully interact (e.g. accessChecks) with an application event.
     * @param {string} eventName Name of application event (e.g. c:myAppEvt)
     * @param {Object.<string, Object>} eventArgs The event attributes
     * 
     * @returns {Boolean} A boolean value indicating whether an application level event with specified name was found and fired or not
     */
    $T.fireApplicationEvent = function(eventName, eventArgs){
        var eventFired = false;
        runInsideCallbackClosure(function(){
            var appEvent = $A.get("e."+eventName);
            if(appEvent){
                if(eventArgs){
                    appEvent.setParams(eventArgs);
                }
                appEvent.fire();
                eventFired = true;
            }
        });
        return eventFired;
    }

    /**
     * Clears the components registered to cmpsToCleanup list.
     */
    $T.clearRenderedTestComponents = function() {
        while (cmpsToCleanup.length) {
            var globalId = cmpsToCleanup.shift();
            var cmp = $A.getComponent(globalId);
            cmp.destroy();
        }
    }

    /**
     * [Internal Only] used by test runner component to allow execution of test code within a closure
     */
    $T._setContexualRunner = function(fn){
        contexualRunner = fn;
    }

    /**
     * Runs provided function within a closure to allow interaction with lightning API (e.g. avoid accessCheck errors) 
     * with proper context   
     */
    var runInsideCallbackClosure = function(fn){
        if(!contexualRunner){
            throw new Error("callback is not set");
        }
        contexualRunner(fn);
    }
})(this);