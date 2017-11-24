/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

public class CashSlot {
    private int contents;
    private int available;
    
    public int getContents() {
        return contents;
    }

    public void load(int dollars){
        available = dollars;
    }

    public void dispense(int requested){
        if (available >= requested) {
            contents = requested;
            available -= requested;
        } else {
            throw new RuntimeException("Insufficient ATM funds");
        }
    }
}

