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
import javax.swing.JOptionPane;

import nicebank.Account;
import nicebank.Teller;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.events.EventFiringWebDriver;

import org.springframework.beans.factory.annotation.Autowired;

public class AtmUserInterface implements Teller {
    @Autowired
    private EventFiringWebDriver webDriver;

    public void withdrawFrom(Account account, int amount) {
            webDriver.get("http://localhost:" + hooks.ServerHooks.PORT);
            webDriver.findElement(By.id("amount")).sendKeys(String.valueOf(amount));
            webDriver.findElement(By.id("withdraw")).click();
    }
    
    public void type(int amount) {
        webDriver.get("http://localhost:" + hooks.ServerHooks.PORT);
        WebElement input = webDriver.findElement(By.id("amount"));
        String amountString = String.valueOf(amount);
        input.sendKeys(amountString);
    }
    
    public boolean isDisplaying(String message) {
        List<WebElement> list = webDriver
            .findElements(By.xpath("//*[contains(text(),'" + message + "')]"));
        return (list.size() > 0);        
    }
}
