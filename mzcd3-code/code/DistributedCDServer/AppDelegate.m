/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "AppDelegate.h"

#import <netinet/in.h>
#import <sys/socket.h>

#define kStoreName @"DistributedCDServer.sql"
#define kServerName @"DistributedCDServer"

@interface AppDelegate() <NSNetServiceDelegate>

- (int)portFromSocket:(NSSocketPort*)socket;
- (void)disconnect;
- (void)populateDefaultData:(NSManagedObjectContext*)moc;
- (void)startBroadcasting;
- (void)logError:(NSError*)error;

@end

@implementation AppDelegate

- (void)disconnect
{
  //Stop the save timer
  [saveTimer invalidate], saveTimer = nil;
  
  //Disconnect the Bonjour stack
  [myService stop];
  [myService release], myService = nil;
  [myConnection invalidate];
  [myConnection release], myConnection = nil;
  [receiveSocket release], receiveSocket = nil;
  
  //Also disconnect the Core Data stack
  [managedObjectContext release], managedObjectContext = nil;
  [psc release], psc = nil;
  [mom release], mom = nil;
}

- (void)dealloc 
{
  //Never fires in the AppDelegate
  [super dealloc];
}

- (void)logError:(NSError*)error
{
  id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
  if (!sub) {
    sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
  }
  if (!sub) {
    NSLog(@"%@:%s Error Received: %@", [self class], __PRETTY_FUNCTION__,
          [error localizedDescription]);
    return;
  }
  
  if ([sub isKindOfClass:[NSArray class]] || 
      [sub isKindOfClass:[NSSet class]]) {
    for (NSError *subError in sub) {
      NSLog(@"%@:%s SubError: %@", [self class], __PRETTY_FUNCTION__,
            [subError localizedDescription]);
    }
  } else {
    NSLog(@"%@:%s exception %@", [self class], __PRETTY_FUNCTION__, 
          [sub description]);
  }
}

#pragma mark -
#pragma mark Core Data Methods

- (NSString*)applicationSupportFolder 
{
  NSArray *p = nil;
  p = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, 
                                          NSUserDomainMask, YES);
  NSString *basePath = nil;
  basePath = ([p count] > 0) ? [p objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"DistributedCDServer"];
}

- (void)populateDefaultData:(NSManagedObjectContext*)moc
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"Test" 
                                 inManagedObjectContext:moc]];
  
  NSError *error = nil;
  NSArray *objects = [moc executeFetchRequest:request error:&error];
  [request release], request = nil;
  
  if (error) {
    NSLog(@"%@:%s error: %@", [self class], __PRETTY_FUNCTION__, error);
    return;
  }
  if ([objects count]) return;

  int index;
  int childIndex;
  int childCount;
  NSManagedObject *temp = nil;
  NSManagedObject *child = nil;
  for (index = 0; index < 10; ++index) {
    temp = [NSEntityDescription insertNewObjectForEntityForName:@"Test" 
                                         inManagedObjectContext:moc];
    [temp setValue:[NSString stringWithFormat:@"Name %i", index] 
            forKey:@"name"];
    childCount = rand() % 5;
    for (childIndex = 0; childIndex < childCount; ++childIndex) {
      child = [NSEntityDescription insertNewObjectForEntityForName:@"Child"
                                            inManagedObjectContext:moc];
      [child setValue:[NSString stringWithFormat:@"Child %i", childIndex] 
               forKey:@"name"];
      [child setValue:temp forKey:@"parent"];
    }
  }
}

- (NSManagedObjectModel*)managedObjectModel 
{
  if (mom) return mom;
	
  mom = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  return mom;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator 
{
  if (psc) return psc;
  
  NSFileManager *fileManager;
  NSString *path = nil;
  NSURL *url = nil;
  NSError *error = nil;
  
  fileManager = [NSFileManager defaultManager];
  path = [self applicationSupportFolder];
  if (![fileManager fileExistsAtPath:path isDirectory:NULL] ) {
    if (![fileManager createDirectoryAtPath:path
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error]) {
      [[NSApplication sharedApplication] presentError:error];
      return nil;
    }
  }
  
  path = [path stringByAppendingPathComponent:kStoreName];
  url = [NSURL fileURLWithPath:path];
  NSManagedObjectModel *_mom = [self managedObjectModel];
  psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_mom];
  if (![psc addPersistentStoreWithType:NSSQLiteStoreType 
                         configuration:nil 
                                   URL:url 
                               options:nil 
                                 error:&error]) {
    [[NSApplication sharedApplication] presentError:error];
  }    
  
  return psc;
}

- (NSManagedObjectContext*)managedObjectContext
{
  if (managedObjectContext) return managedObjectContext;
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
  }
  
  [self populateDefaultData:managedObjectContext];
  
  return managedObjectContext;
}

#pragma mark -
#pragma mark Application Delegate Methods

- (IBAction)saveAction:(id)sender 
{
  NSError *error = nil;
  NSManagedObjectContext *context = [self managedObjectContext];
  if (![context hasChanges]) return;
  if (![context save:&error]) {
    [self logError:error];
  }
}

- (NSUndoManager*)windowWillReturnUndoManager:(NSWindow*)window 
{
  return [[self managedObjectContext] undoManager];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
  [self startBroadcasting];
  
  saveTimer = [NSTimer scheduledTimerWithTimeInterval:(5.0 * 60.0)
                                               target:self 
                                             selector:@selector(saveAction:) 
                                             userInfo:nil 
                                              repeats:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender 
{
  NSError *error = nil;
  
  if (!managedObjectContext) {
    [self disconnect];
    return NSTerminateNow; 
  }
  
  if (![managedObjectContext commitEditing]) {
    return NSTerminateCancel;
  }
  
  if (![managedObjectContext hasChanges]) {
    [self disconnect];
    return NSTerminateNow;
  }
  
  if ([managedObjectContext save:&error]) {
    [self disconnect];
    return NSTerminateNow;
  }

  [self logError:error];

  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Could not save changes while quitting. Quit anyway?"];
  [alert addButtonWithTitle:@"Quit anyway"];
  [alert addButtonWithTitle:@"Cancel"];
  int alertReturn = [alert runModal];
  [alert release], alert = nil;

  if (alertReturn == NSAlertAlternateReturn) {
    return NSTerminateCancel;	
  }
  
  [self disconnect];
  return NSTerminateNow;
}

#pragma mark -
#pragma mark NetService delegate methods

- (void)netService:(NSNetService*)service 
     didNotPublish:(NSDictionary*)error
{
  NSLog(@"%@:%s entered\n%@", [self class], __PRETTY_FUNCTION__, error);
  [[NSApplication sharedApplication] terminate:self];
}

- (int)portFromSocket:(NSSocketPort*)socket
{
  struct sockaddr *address = (struct sockaddr*)[[receiveSocket address] bytes];
  uint16_t port;
  if (address->sa_family == AF_INET) {
    port = ntohs(((struct sockaddr_in*)address)->sin_port);
  } else if (address->sa_family == AF_INET6) {
    port = ntohs(((struct sockaddr_in6*)address)->sin6_port);
  } else {
    @throw [NSException exceptionWithName:@"Socket Error" 
                                   reason:@"Unknown network type" 
                                 userInfo:nil];
  }
  return port;
}

- (void)startBroadcasting
{
  receiveSocket = [[NSSocketPort alloc] init];
  int receivePort = [self portFromSocket:receiveSocket];
  myConnection = [[NSConnection alloc] initWithReceivePort:receiveSocket
                                                  sendPort:nil];
  [myConnection setRootObject:self];
  myService = [[NSNetService alloc] initWithDomain:kDomainName 
                                              type:kServiceName 
                                              name:kServerName
                                              port:receivePort];
  [myService setDelegate:self];
  [myService publish];
}

#pragma mark -
#pragma mark PPDistributedProtocol methods

- (oneway void)ping
{
  NSLog(@"%@:%s received", [self class], __PRETTY_FUNCTION__);
}

- (byref NSArray*)allObjects
{
  NSManagedObjectContext *context = [self managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Test" 
                                            inManagedObjectContext:context];
  [request setEntity:entity];
  
  NSError *error = nil;
  NSArray *objects = [context executeFetchRequest:request error:&error];
  [request release], request = nil;
  
  if (error) {
    NSLog(@"%@:%s error: %@", [self class], __PRETTY_FUNCTION__, error);
    return nil;
  }
  return objects;
}

- (byref NSManagedObject*)createObject;
{
  NSManagedObjectContext *context = [self managedObjectContext];
  NSManagedObject *object = nil;
  object = [NSEntityDescription insertNewObjectForEntityForName:@"Test"
                                         inManagedObjectContext:context];
  return object;
}

- (oneway void)deleteObject:(byref NSManagedObject*)object;
{
  NSManagedObjectContext *context = [self managedObjectContext];
  NSManagedObject *local = [context objectWithID:[object objectID]];
  if ([local isDeleted]) {
    return;
  }
  if (![local isInserted]) {
    [self saveAction:self];
  }
  [context deleteObject:local];
}

/
- (byref NSManagedObject*)createChildForObject:(byref NSManagedObject*)parent;
{
  NSManagedObjectContext *context = [self managedObjectContext];
  NSManagedObject *localParent = [context objectWithID:[parent objectID]];
  NSManagedObject *object = nil;
  object = [NSEntityDescription insertNewObjectForEntityForName:@"Child"
                                         inManagedObjectContext:context];
  [object setValue:localParent forKey:@"parent"];
  return object;
}

- (byref NSArray*)objectsOfName:(bycopy NSString*)name 
                  withPredicate:(bycopy NSPredicate*)predicate;
{
  NSManagedObjectContext *context = [self managedObjectContext];
  NSError *error = nil;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:name 
                                 inManagedObjectContext:context]];
  [request setPredicate:predicate];
  NSArray *results = [context executeFetchRequest:request error:&error];
  [request release], request = nil;
  if (error) {
    NSLog(@"%@:%s Error on fetch %@", [self class], __PRETTY_FUNCTION__, error);
    return nil;
  }
  return results;
}

@end