<aura:application >

    <c:lts_mochaRunner testspecs="{!join(',', 
    	$Resource.mochaExampleTests
    )}" />

</aura:application>