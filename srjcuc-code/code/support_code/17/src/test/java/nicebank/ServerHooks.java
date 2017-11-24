/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package nicebank;

import cucumber.api.java.After;
import cucumber.api.java.Before;

import java.io.IOException;

import support.KnowsTheDomain;

public class ServerHooks {
    public static final int PORT = 8887;

    private AtmServer atmServer;
    private KnowsTheDomain helper;

    public ServerHooks(KnowsTheDomain helper) {
        this.helper = helper;
    }

    @Before
    public void startServer() throws IOException {
        atmServer = new AtmServer(PORT, helper.getCashSlot(), helper.getMyAccount());
        atmServer.start();
    }

    @After
    public void stopServer() throws IOException {
        atmServer.stop();
    }
}
