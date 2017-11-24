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
    
    private static boolean bypassTellerUI = false;
    
    public static void reset() {
        bypassTellerUI = false;
    }
    
    public static void bypassTellerUI() {
        bypassTellerUI = true;
    }

    public static AtmInterface createAtmInterface() {            
        if (bypassTellerUI) {
            return new AtmProgrammaticInterface();
        } else {                
            return new AtmUserInterface();
        }
    }
}
