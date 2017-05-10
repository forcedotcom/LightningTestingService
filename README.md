# Lightning Component Tests
## Project Goal
Showcase reusable functional test patterns (testing eventing, renderering, callbacks etc.) for Lightning Components using Jasmine (a popular open-sourced javascript testing framework). 

Integration between Lightning and Jasmine showcased in this repo will also be made available as an unmanaged package. Developers building Lightning Components will be able to focus on authoring tests for their customizations by using the package in conjunction with SFDX integration (for streamlined dev and CI workflow).

## Metadata Visualization and Runtime Flowchart
![metadata visualization and runtime flowchart](doc-resources/metadata-visualization-and-runtime-flowchart.png)

## Getting Started
##### Sample wrapper test application: [Test.app](lightning-component-tests/test/default/aura/Tests/Tests.app)
##### Example Lightning component tests: [exampleTests.resource](lightning-component-tests/test/default/staticresources/exampleTests.resource)
##### Directory containing sample [components](lightning-component-tests/main/default/aura) under test

## Dev Workflow
### Prerequisites
* SFDX CLI 
* Environment Hub Setup for SFDX CLI
* Force IDE 2

### Scratch Org Creation
* Login to hub org
<pre><code>
sfdx force:auth:web:login -d
</code></pre>

* Customize scratch org [config](/config/workspace-scratch-def.json) by specifying company name, email address etc.

* Create a Scratch Org and set it as default
<pre><code>
sfdx force:org:create -s -f config/workspace-scratch-def.json -a scratch1
</code></pre>

### Pushing Metadata to Scratch Org
* Push metadata to scratch org
<pre><code>
sfdx force:source:push 
</code></pre>

* Login to scratch org
<pre><code>
sfdx force:org:open
</code></pre>

* For a manual run, visit one of the test apps (e.g. /c/Tests.app)
![sample run](/doc-resources/SampleTestRun.png)

* For Automated run, use special purpose sfdx cli command (coming soon) or execute as an integration test,
<pre><code>
sfdx force:testrunner:run  -f test/test-runner-config.json -c local -j integration
</code></pre>

### [Alternative] Pushing Metadata to Developer Edition Org
If you do not have environment-hub setup and would like to give this repo a try, it is possible to push the metadata to a developer edition org instead,
<pre><code>
sfdx force:auth:web:login -s
sfdx force:source:push -f
</code></pre>

### Debugging Tests
* Browser Dev Tools can be used to debug
![sample debugging](/doc-resources/SampleDebugging.png)
