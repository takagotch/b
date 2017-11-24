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
import org.javalite.activejdbc.Base;

public class KnowsTheAccount {
    private Account myAccount;

    public KnowsTheAccount() {
        if (!Base.hasConnection()) {
            Base.open(
                    "com.mysql.jdbc.Driver",
                    "jdbc:mysql://localhost/bank",
                    "teller", "password");
        }

        Account.deleteAll();
    }

    public Account getMyAccount() {
        if (myAccount == null){
            myAccount = new Account(1234);
            myAccount.saveIt();
        }

        return myAccount;
    }
}
