/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package support;

import nicebank.Account;
import nicebank.CashSlot;
import nicebank.Teller;

public class KnowsTheDomain {
    private Account myAccount;
    private Teller teller;
    private CashSlot cashSlot;

    public Account getMyAccount() {
      if (myAccount == null){
        myAccount = new Account();
      }

      return myAccount;
    }

    public Teller getTeller() {
      if (teller == null){
        teller = new AtmUserInterface();
      }
      
      return teller;
    }
       
    public CashSlot getCashSlot() {
      if (cashSlot == null){
        cashSlot = new CashSlot();
      }
  
      return cashSlot;
    }
}
