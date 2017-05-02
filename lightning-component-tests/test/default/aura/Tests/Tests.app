<aura:application extends="force:slds">
    
    <c:BaseTestRunnerCmp testspecs="{!join(',', 
    	$Resource.helloWorldTests,
		$Resource.exampleTests,
		$Resource.lightningDataServiceTests
    )}"/>
    <div aura:id="renderTestComponents" id="renderTestComponents"></div>
</aura:application>