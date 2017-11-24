/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
 
public class WithdrawalServlet extends HttpServlet
{
    private CashSlot cashSlot;
    private Account account;
    
    public WithdrawalServlet(CashSlot cashSlot, Account account) {
        this.cashSlot = cashSlot;
        this.account = account;
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
                                                throws ServletException, IOException
    {
        int amount = Integer.parseInt(request.getParameter("amount"));
        
        try {
            AutomatedTeller.withdrawFrom(cashSlot, account, amount);

            response.setContentType("text/html");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().println(
                 "<html><head><title>ATM</title></head>" +
                 "<body>Please take your $" + amount + "</body></html>");
        }
        catch (RuntimeException e) {
            response.setContentType("text/html");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().println(
                 "<html><head><title>ATM</title></head>" +
                 "<body>" + e.getMessage() + "</body></html>");
        }
}
}