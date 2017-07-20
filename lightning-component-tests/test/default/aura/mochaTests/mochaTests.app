<aura:application >

    <c:lts_mochaRunner testFiles="{!join(',', 
    	$Resource.mochaExampleTests
    )}" />

</aura:application>