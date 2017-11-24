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
 
public class ValidationServlet extends HttpServlet
{
    private CashSlot cashSlot;

    public ValidationServlet(CashSlot cashSlot) {
        this.cashSlot = cashSlot;
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
                                                throws ServletException, IOException
    {
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_OK);

        int amount = Integer.parseInt(request.getParameter("amount"));

        if (cashSlot.canDispense(amount)) {
            response.getWriter().println("{\"content\":\"\"}");
        } else {
            response.getWriter().println(
                "{\"content\":\"Insufficient ATM funds\"}");
        }
    }
}