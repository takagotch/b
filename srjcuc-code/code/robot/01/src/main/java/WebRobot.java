/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
import javax.swing.JOptionPane;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.events.EventFiringWebDriver;

public class WebRobot {
    public static void main(String[] args){
        FirefoxDriver firefoxDriver = new FirefoxDriver();
        EventFiringWebDriver webDriver = new EventFiringWebDriver(firefoxDriver);
        
        webDriver.get("http://www.google.com");
        // .... etc
        ask("Click to finish");
        webDriver.quit();
    }
    
    private static void ask(String question) {
      JOptionPane.showMessageDialog(null, question, "Ask for response", 
        JOptionPane.PLAIN_MESSAGE);
    }
}
