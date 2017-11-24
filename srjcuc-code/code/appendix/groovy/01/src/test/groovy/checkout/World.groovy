/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package checkout

/*
 * Change which import below is commented out to switch between the
 * Java and Groovy implementations of the checkout code.
 */
//import checkout.java.*
import checkout.groovy.*

this.metaClass.mixin(cucumber.api.groovy.Hooks)

class CheckoutWorld {
  def priceList = new PriceList()
  def checkout = new Checkout(priceList)
}

World {
  new CheckoutWorld()
}
