/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import org.javalite.activejdbc.Model;

public class Account extends Model {
  private TransactionQueue queue = new TransactionQueue();

  public Account() {}
  
  public Account(int number){
      setInteger("number", number);
      setString("balance", "0.00");
  }

  public void credit(Money amount) {
      queue.write("+" + amount.toString() + "," + getNumber());
  }
  
  public void debit(int dollars) {
      Money amount = new Money(dollars, 0);
      queue.write("-" + amount.toString() + "," + getNumber());
  }
  
  public int getNumber() {
      return getInteger("number");
  }

  public Money getBalance() {
      return new Money(getString("balance"));
  }

  public void setBalance(Money amount) {
      setString("balance", amount.toString().substring(1));
      saveIt();
  }
}
