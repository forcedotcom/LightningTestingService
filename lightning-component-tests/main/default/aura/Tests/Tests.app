<aura:application >
	<aura:attribute name="testspecs" type="String[]" default="{!$Resource.jasmineTest}"/>
    
    <c:BaseTestRunnerCmp testspecs="{!v.testspecs}"/>
    <div aura:id="renderTestComponents"></div>
</aura:application>