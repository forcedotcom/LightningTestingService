<aura:application extends="force:slds">
    
    <c:BaseTestRunnerCmp testspecs="{!join(',', 
        $Resource.exampleTestsUsingSpies                         
    )}"/>
    <div aura:id="renderTestComponents"></div>
</aura:application>