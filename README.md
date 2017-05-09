# Lightning Component Tests
## Project Goal
Showcase reusable functional test patterns (testing eventing, renderering, callbacks etc.) for Lightning Components using Jasmine (a popular open-sourced javascript testing framework). 

Integration between Lightning and Jasmine showcased in this repo will also be made avaialble as an unmanaged package. Developers building Lightning Components will be able to focus on authoring tests for their customizations by using the package in conjunction with SFDX integration (for streamlined dev and CI workflow).

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
<code>
sfdx force:auth:web:login -d
</code>

* Create a Scratch Org and set it as default
<code>
sfdx force:org:create -s -f config/workspace-scratch-def.json -a scratch1
</code>

### Pushing Metadata to Scratch Org
* Push metadata to scratch org
<code>
sfdx force:source:push 
</code>

* Login to scratch org
<code>
sfdx force:org:open
</code>

* For a manual run, visit one of the test apps (e.g. /c/Tests.app)
![sample run](/doc-resources/SampleTestRun.png)

* For Automated run, use special purpose sfdx cli command (coming soon) or execute as an integration test,
<code>
sfdx force:testrunner:run  -f test/test-runner-config.json -c local -j integration
</code>

### Debugging Tests
* Browser Dev Tools can be used to step through and debugging issues
![sample debugging](/doc-resources/SampleDebugging.png)
