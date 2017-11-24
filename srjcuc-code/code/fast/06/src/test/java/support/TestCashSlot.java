/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package support;

import nicebank.CashSlot;

public class TestCashSlot extends CashSlot {
    private boolean faulty;
    
    public TestCashSlot() {
        super.load(1000);
    }
    
    public void injectFault() {
        faulty = true;
    }
    
    public void dispense(int dollars){
        if (faulty) {
            throw new RuntimeException("Out of order");
        } else {
            super.dispense(dollars);
        }
    }
}
