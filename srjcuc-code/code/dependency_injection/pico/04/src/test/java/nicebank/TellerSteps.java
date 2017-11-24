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

import support.KnowsTheAccount;
import support.AtmUserInterface;

public class TellerSteps {

  KnowsTheAccount accountHelper;
  Teller teller;

  public TellerSteps(AtmUserInterface teller, KnowsTheAccount accountHelper) {
      this.teller = teller;
      this.accountHelper = accountHelper;
  }
      
  @When("^I withdraw \\$(\\d+)$")
  public void iWithdraw$(int amount) throws Throwable {
      teller.withdrawFrom(accountHelper.getMyAccount(), amount);
  }
}