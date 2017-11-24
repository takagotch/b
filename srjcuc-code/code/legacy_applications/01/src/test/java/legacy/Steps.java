/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package legacy;

import cucumber.api.java.en.*;

import org.junit.*;

public class Steps {
    @Given("^the price of a bottle of shampoo is \\$(\\d+)$")
    public void thePriceOfABottleOfShampooIs$(int itemPrice) throws Throwable {
    }

    @When("^I scan (\\d+) bottles of shampoo$")
    public void iScanBottlesOfShampoo(int itemCount) throws Throwable {
    }

    @Then("^the price should be \\$(\\d+)$")
    public void thePriceShouldBe$(int expectedTotal) throws Throwable {
        int priceCharged = 2; // Here we would call our legacy system
        Assert.assertEquals(expectedTotal, priceCharged);
    }
}