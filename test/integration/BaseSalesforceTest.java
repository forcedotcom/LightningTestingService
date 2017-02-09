package test.integration;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

import org.junit.*;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.*;
import org.openqa.selenium.phantomjs.*;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;

import com.google.common.base.Function;
import org.openqa.selenium.support.ui.*;

/**
 * Base test.
 */
public class BaseSalesforceTest {
    private static final String DEFAULT_SELENIUM_URL = "http://127.0.0.1:4444/wd/hub";

    protected WebDriver driver;
    private final String mode;

    BaseSalesforceTest() {
        mode = getProperty("WEBKIT_MODE", true);
    }

    @Before
    public void setup() throws MalformedURLException {
        DesiredCapabilities caps = DesiredCapabilities.chrome();

        switch (mode) {
            case "PHANTOM":
                // USING PHANTOM
                caps = new DesiredCapabilities();
                caps.setCapability(
                    PhantomJSDriverService.PHANTOMJS_EXECUTABLE_PATH_PROPERTY,
                    getProperty("PHANTOM_BINARY_PATH")
                );
                driver = new  PhantomJSDriver(caps);
                driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);
                driver.manage().window().setSize(new Dimension(1280, 1024));
                break;
            case "SAUCELABS":
                // USING SAUCELABS
                final String USERNAME = getProperty("SAUCE_USERNAME");
                final String ACCESS_KEY = getProperty("SAUCE_ACCESS_KEY");
                final String URL = "http://" + USERNAME + ":" + ACCESS_KEY + "@ondemand.saucelabs.com:80/wd/hub";
                driver = new RemoteWebDriver(new URL(URL), caps);
                break;
            default:
                // USING LOCAL SELENIUM
                driver = new RemoteWebDriver(new URL(DEFAULT_SELENIUM_URL), caps);
        }
    }

    @After
    public void teardown() {
        if (driver != null) {
            driver.quit();
        }
    }

    protected String login() {
        return login(null);
    }

    protected String login(String retUrl) {
        String instanceUrl = getProperty("SALESFORCE_INSTANCE_URL");
        String accessToken = getProperty("SALESFORCE_ACCESS_TOKEN");

        String frontDoorUrl = String.format("%s/secur/frontdoor.jsp?sid=%s", instanceUrl, accessToken);

        if (retUrl != null) {
            frontDoorUrl += ("&retURL=" + retUrl);
        }

        driver.get(frontDoorUrl);
        return driver.getPageSource();
    }

    public WebElement fluentWait(final By locator) {
        int timeout = 10;

        if (mode.equals("PHANTOM")) {
            // Phantom is much slower, it seems... for headless...
            timeout = 20;
        }

        Wait<WebDriver> wait = new FluentWait<WebDriver>(driver)
                .withTimeout(timeout, TimeUnit.SECONDS)
                .pollingEvery(1, TimeUnit.SECONDS)
                .ignoring(NoSuchElementException.class);

        WebElement foo = wait.until(new Function<WebDriver, WebElement>() {
            @Override
            public WebElement apply(WebDriver driver) {
                return driver.findElement(locator);
            }
        });

        return foo;
    };

    private String getProperty(String name) {
        return getProperty(name, false);
    }

    private String getProperty(String name, Boolean allowEmpty) {
        String prop = System.getProperty(name);

        if (isEmpty(prop)) {
            prop = System.getenv(name);
        }

        if (isEmpty(prop) && !allowEmpty) {
            throw new IllegalArgumentException("Property '" + name + "' not provided.");
        }

        if (prop == null) {
            prop = "";
        }

        return prop;
    }

    protected boolean isEmpty(String str) {
        return (str == null || str.length() == 0);
    }
}
