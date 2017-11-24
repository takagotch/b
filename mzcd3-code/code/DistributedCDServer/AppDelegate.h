/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPDistributedProtocol.h"

@interface AppDelegate : NSObject <PPDistributedProtocol>
{
  IBOutlet NSWindow *window;
  
  NSPersistentStoreCoordinator *psc;
  NSManagedObjectModel *mom;
  NSManagedObjectContext *managedObjectContext;
  
  NSSocketPort *receiveSocket;
  NSSocketPort *sendSocket;
  
  NSNetService *myService;
  NSConnection *myConnection;
  
  NSTimer *saveTimer;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;
- (NSManagedObjectModel*)managedObjectModel;
- (NSManagedObjectContext*)managedObjectContext;

- (IBAction)saveAction:sender;

@end
