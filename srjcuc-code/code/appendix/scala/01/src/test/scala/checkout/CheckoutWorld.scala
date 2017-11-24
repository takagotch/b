/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package checkout

import cucumber.api.Scenario
import cucumber.api.scala.{ScalaDsl, EN}

object CheckoutWorld extends ScalaDsl with EN {

  var priceList: PriceList = _
  var checkout: Checkout = _
  
  Before(){ scenario : Scenario =>
    priceList = new PriceList
    checkout = new Checkout(priceList)
  }
}