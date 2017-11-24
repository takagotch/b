/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
import org.junit.*;
import static org.junit.Assert.*;

public class AssertionExample {
    
  public static void main(String[] args) {
    try {
      assertTrue(false);
    } catch (AssertionError e) {
      System.out.print("Exception was raised was ");
      System.out.println(e.getClass().getName());
    }
  }
}