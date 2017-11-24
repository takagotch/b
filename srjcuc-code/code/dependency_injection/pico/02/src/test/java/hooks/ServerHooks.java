/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package hooks;

import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.Scenario;

import nicebank.AtmServer;
import support.KnowsTheAccount;
import support.KnowsTheCashSlot;

public class ServerHooks {
    public static final int PORT = 8887;

    private AtmServer server;
    private KnowsTheAccount accountHelper;
    private KnowsTheCashSlot cashSlotHelper;

    public ServerHooks(KnowsTheAccount accountHelper, KnowsTheCashSlot cashSlotHelper) {
        this.accountHelper = accountHelper;
        this.cashSlotHelper = cashSlotHelper;
    }
    
    @Before
    public void startServer() throws Exception {
        server = new AtmServer(PORT, cashSlotHelper.getCashSlot(), accountHelper.getMyAccount());
        server.start();
    }

    @After
    public void stopServer() throws Exception {
        server.stop();
    }
}