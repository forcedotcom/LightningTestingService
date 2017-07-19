<aura:application extends="force:slds" description="Sample wrapper test app">

    <c:lts_jasmineRunner testspecs="{!join(',', 
    	$Resource.jasmineHelloWorldTests,
		$Resource.jasmineExampleTests,
		$Resource.jasmineLightningDataServiceTests
    )}" />

</aura:application>