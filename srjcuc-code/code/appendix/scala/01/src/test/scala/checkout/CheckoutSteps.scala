/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package checkout

import cucumber.api.scala.{ScalaDsl, EN}
import org.junit.Assert._

class CheckoutSteps extends ScalaDsl with EN {

  When("""^I scan a "(.*?)"$"""){ (itemName:String) =>
    CheckoutWorld.checkout.scan(itemName)
  }
  
  Then("""^the total is (\d+)c$"""){ (expectedTotal:Int) =>
    assertEquals(expectedTotal, CheckoutWorld.checkout.getTotal)
  }
}