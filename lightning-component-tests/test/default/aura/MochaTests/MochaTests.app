<aura:application >
    <c:lts_mochaRunner testspecs="{!join(',', 
    	$Resource.mochaExampleTests
    )}" />

    <!--  placeholder div which example test specs use to render components under test -->
    <div aura:id="renderTestComponents" id="renderTestComponents"></div>
</aura:application>