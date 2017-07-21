<aura:application>

    <c:lts_jasmineRunner testFiles="{!join(',', 
    	$Resource.jasmineHelloWorldTests,
		$Resource.jasmineExampleTests,
		$Resource.jasmineLightningDataServiceTests
    )}" />

</aura:application>
