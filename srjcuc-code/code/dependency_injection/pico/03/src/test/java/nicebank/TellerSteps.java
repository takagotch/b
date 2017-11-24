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
import support.KnowsTheTeller;

public class TellerSteps {

  KnowsTheAccount accountHelper;
  KnowsTheTeller tellerHelper;

  public TellerSteps(KnowsTheTeller tellerHelper, KnowsTheAccount accountHelper) {
      this.tellerHelper = tellerHelper;
      this.accountHelper = accountHelper;
  }
      
  @When("^I withdraw \\$(\\d+)$")
  public void iWithdraw$(int amount) throws Throwable {
      tellerHelper.getTeller().withdrawFrom(accountHelper.getMyAccount(), amount);
  }
}