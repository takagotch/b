/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package fruit;

import com.google.gson.Gson;

import cucumber.api.java.en.*;

import java.io.PrintWriter;
import java.util.List;

public class FruitSteps {
    @Given("^the system knows about the following fruit:$")
    public void theSystemKnowsAboutTheFollowingFruit(List<Fruit> fruitList)
                                                            throws Throwable {
        Gson gson = new Gson();
        PrintWriter writer = new PrintWriter("fruit.json", "UTF-8");
        writer.println(gson.toJson(fruitList));
        writer.close();
    }
}