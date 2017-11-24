/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.Scenario;

public class SomeTestHooks {
    @Before
    public void before_calling_scenario() {
        System.out.println("*********** About to start the scenario.");
    }

    @After
    public void after_running_scenario(Scenario scenario) {
        System.out.println("*********** Just finished running scenario: "
                            + scenario.getStatus());
    }
}
