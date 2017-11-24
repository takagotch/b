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
import cucumber.api.Transform;

import org.junit.*;

import support.KnowsTheDomain;
import transforms.MoneyConverter;

public class AccountSteps {
  KnowsTheDomain helper;

  public AccountSteps() {
    helper = new KnowsTheDomain();
  }
      
  @Given("^I have deposited (\\$\\d+\\.\\d+) in my account$")
  public void iHaveDeposited$InMyAccount(@Transform(MoneyConverter.class) Money amount) 
                                                              throws Throwable {
    helper.getMyAccount().deposit(amount);
    
    Assert.assertEquals("Incorrect account balance -", amount, helper.getMyAccount().getBalance()); 
  }
}