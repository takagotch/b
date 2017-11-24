/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

import cucumber.api.java.en.*;
import cucumber.api.PendingException;

import hooks.ServerHooks;

import java.net.HttpURLConnection;

import org.junit.*; 

public class RestSteps {
    private ClientResponse response;
    
    @When("^the client requests GET /fruits$")
    public void theClientRequestsGETFruits() throws Throwable {
        try {

            Client client = Client.create();

            WebResource webResource = client
                    .resource("http://localhost:" + ServerHooks.PORT + "/fruits");

            response = webResource.type("application/json")
                    .get(ClientResponse.class);
        } catch (RuntimeException r) {
            throw r;
        } catch (Exception e) {
            System.out.println("Exception caught");
            e.printStackTrace();
        }

        Assert.assertEquals("Did not receive OK response: ", 
            HttpURLConnection.HTTP_OK, response.getStatus());
    }

    @Then("^the response should be JSON:$")
    public void theResponseShouldBeJSON(String jsonExpected) throws Throwable {
        Assert.assertEquals("Incorrect JSON representation.", 
                            jsonExpected, response.getEntity(String.class));
    }
}