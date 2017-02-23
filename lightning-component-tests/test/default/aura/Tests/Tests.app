<aura:application extends="force:slds">
    
    <c:BaseTestRunnerCmp testspecs="{!join(',', 
    	$Resource.helloWorldTests, 
        $Resource.exampleTests                         
    )}"/>
    <div aura:id="renderTestComponents"></div>
</aura:application>