/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Scanner;

public class BalanceStore {
    private static String BALANCE_FILE_PATH = "./balance"; 

    public static void clear() {
        new File(BALANCE_FILE_PATH).delete();

        setBalance(new Money(0,0));
    }

    public static Money getBalance() { 
        File balanceFile = new File(BALANCE_FILE_PATH); 
        Scanner scanner = null;
        try {
            scanner = new Scanner(balanceFile); 
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        // Probably need regex here
        Money balance = new Money(scanner.nextLine()); 
        scanner.close();
        
        return balance;
    }
    
    public static void setBalance(Money newBalance){ 

        PrintWriter writer = null;
        try {
            writer = new PrintWriter(BALANCE_FILE_PATH, "UTF-8");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        writer.println(newBalance.toString()); 
        writer.close();
    }
}