/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package hooks;

import cucumber.api.Scenario;
import cucumber.api.java.After;
import org.openqa.selenium.support.events.EventFiringWebDriver;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.WebDriverException;
import support.MyWebDriver;

public class WebDriverHooks {

    private final EventFiringWebDriver webDriver;

    public WebDriverHooks(MyWebDriver webDriver) {
        this.webDriver = webDriver;
    }

    @After
    public void finish(Scenario scenario) {
        try {
            byte[] screenshot = webDriver.getScreenshotAs(OutputType.BYTES);
            scenario.embed(screenshot, "image/png");
        } catch (WebDriverException somePlatformsDontSupportScreenshots) {
            System.err.println(somePlatformsDontSupportScreenshots.getMessage());
        } finally {
            webDriver.close();
        }
    }
}