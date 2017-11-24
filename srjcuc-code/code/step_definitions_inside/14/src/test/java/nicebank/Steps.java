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
import cucumber.api.Transform;

import org.junit.*;

import transforms.MoneyConverter;

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

    class Teller {
        public void withdrawFrom(Account account, int dollars) {

        }
    }

    class CashSlot {
        public int getContents() {
            return 0;
        }
    }

    class KnowsTheDomain {
        private Account myAccount;
        private CashSlot cashSlot;

        public Account getMyAccount() {
          if (myAccount == null){
            myAccount = new Account();
          }

          return myAccount;
        }
    
        public CashSlot getCashSlot() {
          if (cashSlot == null){
            cashSlot = new CashSlot();
          }
      
          return cashSlot;
        }
    }

    KnowsTheDomain helper;

    public Steps() {
      helper = new KnowsTheDomain();
    }

    @Given("^I have deposited (\\$\\d+\\.\\d+) in my account$")
    public void iHaveDeposited$InMyAccount(
                                  @Transform(MoneyConverter.class) Money amount) 
                                                                throws Throwable {
        helper.getMyAccount().deposit(amount);

        Assert.assertEquals("Incorrect account balance -", 
                                amount, helper.getMyAccount().getBalance()); 
    }

    @When("^I withdraw \\$(\\d+)$")
    public void iWithdraw$(int dollars) throws Throwable {
        Teller teller = new Teller();
        teller.withdrawFrom(helper.getMyAccount(), dollars);
    }

    @Then("^\\$(\\d+) should be dispensed$")
    public void $ShouldBeDispensed(int dollars) throws Throwable {
        Assert.assertEquals("Incorrect amount dispensed -", 
                                            dollars, helper.getCashSlot().getContents());
    }
}