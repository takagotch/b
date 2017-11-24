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

import org.javalite.activejdbc.Base;

import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.events.EventFiringWebDriver;

public class KnowsTheDomain {
    private Account myAccount;
    private Teller teller;
    private CashSlot cashSlot;
    private EventFiringWebDriver webDriver;
    
    public KnowsTheDomain() {
        if (!Base.hasConnection()){
            Base.open(
                "com.mysql.jdbc.Driver",
                "jdbc:mysql://localhost/bank",
                "teller", "password");

                try {
                    Base.connection().setAutoCommit(false);
                } catch (Exception se){
                    // Ignore
                }
        }
    }

    public Account getMyAccount() {
      if (myAccount == null){
        myAccount = new Account(1234);
        myAccount.saveIt();
      }
      
      return myAccount;
    }

    public Teller getTeller() {
      if (teller == null){
        teller = new AtmUserInterface(getWebDriver());
      }
      
      return teller;
    }
       
    public CashSlot getCashSlot() {
      if (cashSlot == null){
        cashSlot = new CashSlot();
      }
  
      return cashSlot;
    }
    
    public EventFiringWebDriver getWebDriver() {
        if (webDriver == null){
          webDriver = new EventFiringWebDriver(new FirefoxDriver());
        }

        return webDriver;
    }
}
