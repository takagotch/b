/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package transforms;

import cucumber.api.Transformer;

import nicebank.Money;

public class MoneyConverter extends Transformer<Money> {
     public Money transform(String amount) {
         String[] numbers = amount.substring(1).split("\\.");
         
         int dollars = Integer.parseInt(numbers[0]);
         int cents = Integer.parseInt(numbers[1]);
         
         return new Money(dollars, cents);
     }
 }

