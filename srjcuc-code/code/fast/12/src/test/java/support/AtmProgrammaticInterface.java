/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package support;

import java.util.List; 

import nicebank.Account;
import nicebank.AutomatedTeller;
import nicebank.CashSlot;

import org.springframework.beans.factory.annotation.Autowired;

public class AtmProgrammaticInterface implements AtmInterface {
    @Autowired
    private CashSlot cashSlot;
    
    RuntimeException runtimeException;

    public void withdrawFrom(Account account, int amount) {
        try {
            AutomatedTeller.withdrawFrom(cashSlot, account, amount);
        } catch (RuntimeException e){
            runtimeException = e;
        }
    }
    
    public void type(int amount) {
        // NOTHING TO BE DONE
    }

    public boolean isDisplaying(String message) {
        // SHOULD THIS BE true OR false OR throw new NotImplementedException();?
        return true;
    }
}
