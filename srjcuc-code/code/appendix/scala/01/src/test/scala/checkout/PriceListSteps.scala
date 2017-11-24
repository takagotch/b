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

class PriceListSteps extends ScalaDsl with EN {

  Given("""^a "(.*?)" costs (\d+)c$"""){ (itemName:String, priceInCents:Int) =>
    CheckoutWorld.priceList.add(itemName, priceInCents)
  }
}