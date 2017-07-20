<aura:application extends="force:slds" description="Sample wrapper test app">

    <c:lts_jasmineRunner testFiles="{!join(',', 
    	$Resource.jasmineHelloWorldTests,
		$Resource.jasmineExampleTests,
		$Resource.jasmineLightningDataServiceTests
    )}" />

</aura:application>