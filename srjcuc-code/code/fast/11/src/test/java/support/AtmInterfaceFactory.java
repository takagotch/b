/***
 * Excerpted from "The Cucumber for Java Book",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/srjcuc for more book information.
***/
package support;

public class AtmInterfaceFactory {

    public static AtmInterface createAtmInterface() {
        String cucumberEnvironment = System.getenv("CUCUMBER_ENVIRONMENT");
            
        if (cucumberEnvironment != null 
                && cucumberEnvironment.equalsIgnoreCase("DEVELOPMENT")) {
            return new AtmProgrammaticInterface();
        } else {                
            return new AtmUserInterface();
        }
    }
}
