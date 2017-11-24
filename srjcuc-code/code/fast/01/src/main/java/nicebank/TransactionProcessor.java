/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import org.javalite.activejdbc.Base;

public class TransactionProcessor {
    private TransactionQueue queue = new TransactionQueue();

    public void process() {
        if (!Base.hasConnection()){
            Base.open(
                "com.mysql.jdbc.Driver",
                "jdbc:mysql://localhost/bank",
                "teller", "password");
        }

        do {
            String message = queue.read();

            if (message != null && message.length() > 0) {
                String[] parts = message.split(",");
                Account account = Account.findFirst("number = ?", parts[1]);
                Money transactionAmount = new Money(parts[0]);

                if (isCreditTransaction(message)){
                    account.setBalance(account.getBalance().add(transactionAmount));
                } else {
                    account.setBalance(account.getBalance().minus(transactionAmount));
                }
            }
        } while (true);
    }

    private boolean isCreditTransaction(String message) {
        return !message.startsWith("-");
    }
}