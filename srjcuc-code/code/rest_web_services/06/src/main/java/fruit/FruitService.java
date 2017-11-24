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
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.Paths;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import java.util.List;
import java.util.ArrayList;
 
@Path("/")
public class FruitService {
    @GET
    @Path("/fruits")
    @Produces(MediaType.APPLICATION_JSON)
    public Fruit[] getAllFruits() {
        List<Fruit> fruits = getFruitsFromFile();
        return fruits.toArray(new Fruit[]{});
    }
    
    private List<Fruit> getFruitsFromFile() {
        String fruitJson = readJsonFruitFile();
        return buildListFromJson(fruitJson);
    }
    
    private String readJsonFruitFile() {
        try {
            java.nio.file.Path path = FileSystems.getDefault().getPath("fruit.json");
            return new String(Files.readAllBytes(path));
        }
        catch (IOException ioe) {
            return "[]";
        }
    }
    
    private List<Fruit> buildListFromJson(String fruitJson) {
        final TypeToken<List<Fruit>> token = new TypeToken<List<Fruit>>() {};
        final Type type = token.getType();
        final Gson gson = new Gson();

        return gson.fromJson(fruitJson, type);        
    }
    
} 
