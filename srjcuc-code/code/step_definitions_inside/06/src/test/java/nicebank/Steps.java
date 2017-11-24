/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import cucumber.api.java.en.*;
import cucumber.api.PendingException;

import org.junit.*;

public class Steps {

    class Account {
        private Money balance = new Money();

        public void deposit(Money amount) {
            balance = balance.add(amount);
        }

        public Money getBalance() {
          return balance;
        }
    }

    @Given("^I have deposited \\$(\\d+)\\.(\\d+) in my account$")
    public void iHaveDeposited$InMyAccount(int dollars, int cents) throws Throwable {
        Account myAccount = new Account();
        Money amount = new Money(dollars, cents);
        myAccount.deposit(amount);

        Assert.assertEquals("Incorrect account balance -", 
                                amount, myAccount.getBalance()); 
    }

    @When("^I request \\$(\\d+)$")
    public void iRequest$(int arg1) throws Throwable {
      // Write code here that turns the phrase above into concrete actions
      throw new PendingException();
    }

    @Then("^\\$(\\d+) should be dispensed$")
    public void $ShouldBeDispensed(int arg1) throws Throwable {
      // Write code here that turns the phrase above into concrete actions
      throw new PendingException();
    }
}