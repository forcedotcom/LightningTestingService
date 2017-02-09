package test.integration;

import org.junit.*;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;


import org.junit.runner.JUnitCore;

/**
 * Property Explorer UI test.
 */
public class IntegrationTest extends BaseSalesforceTest {
    @Test
    public void testComponents() {
    	long longWait = 60 * 3;
    	String appUrl = "/c/tests.app"; 
    	
    	this.login(appUrl);
    	//driver.get("https://locker1-dev-ed.mobile02.blitz.salesforce.com?un=esalman@locker.1&pw=123456&startURL=/c/tests.app");
    	new WebDriverWait(driver, 30).withMessage("Request for component test execution failed.").until(ExpectedConditions.urlContains(appUrl));
    	
    	WebDriverWait wait = new WebDriverWait(driver, longWait);
    	WebElement e = wait.withMessage("Component Test Execution timed out. Visit " + appUrl + " in your test org to debug").
    			until(ExpectedConditions.presenceOfElementLocated(By.id("run_results_tap")));
    	String failureCount = e.getAttribute("data-failure-count");
    	String totalCount = e.getAttribute("data-total-count");
    	Assert.assertEquals(failureCount+"/"+totalCount+" component tests failed. Visit "+appUrl+" for details.","0", failureCount);
    	//Assert.assertEquals(failureCount+" component test(s) failed. Run results, \n"+ e.getAttribute("innerHTML"), "0", failureCount);
    	
    }

    
	public static void main(String[] args) {
		// Instantiate a JUniteCore object
		JUnitCore core = new JUnitCore();

		// Add TAP Reporter Listener to the core object executor
		core.addListener(new TapReporter());

		// Run the test suite
		core.run(IntegrationTest.class);
	}
}
