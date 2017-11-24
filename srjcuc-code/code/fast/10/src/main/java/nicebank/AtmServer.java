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

import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.ContextHandler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

public class AtmServer
{
    private final Server server;
    
    public AtmServer(int port, CashSlot cashSlot, Account account) {
        server = new Server(port);

        ContextHandler resourceContext = new ContextHandler();
        resourceContext.setContextPath("/js");
        ResourceHandler resourceHandler = new ResourceHandler();
        resourceHandler.setResourceBase("src/main/webapp/js");
        resourceContext.setHandler(resourceHandler);
 
        ServletContextHandler servletContext = 
            new ServletContextHandler(ServletContextHandler.SESSIONS);
        servletContext.setContextPath("/");
        servletContext.addServlet(new ServletHolder(
                new WithdrawalServlet(cashSlot, account)),"/withdraw");
        servletContext.addServlet(new ServletHolder(new ValidationServlet(cashSlot)),"/validate");
        servletContext.addServlet(new ServletHolder(new AtmServlet()),"/");

        ContextHandlerCollection contexts = new ContextHandlerCollection();
        contexts.setHandlers(new Handler[] { resourceContext, servletContext });
        server.setHandler(contexts);
    }
    
    public void start() throws Exception {
        server.start();
        System.out.println("Listening on " + server.getURI());
    }

    public void stop() throws Exception {
        server.stop();
        System.out.println("Server shutdown");
    }

    public static void main(String[] args) throws Exception {
        Base.open(
                "com.mysql.jdbc.Driver",
                "jdbc:mysql://localhost/bank",
                "teller", "password");
        CashSlot cashSlot = new CashSlot();
        cashSlot.load(100);
        new AtmServer(9988, cashSlot, new Account(6789)).start();
    }
}
