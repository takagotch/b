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

#define GUID [[NSProcessInfo processInfo] globallyUniqueString]

@interface AppDelegate () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

- (void)startTestTimers;
- (void)disconnect;

@end

@implementation AppDelegate

@synthesize filteredObjects;

- (void)disconnect
{
  [pingTimer invalidate], pingTimer = nil;
  [fetchTimer invalidate], fetchTimer = nil;
  [insertTimer invalidate], insertTimer = nil;
  [deleteTimer invalidate], deleteTimer = nil;
  [childDeleteTimer invalidate], childDeleteTimer = nil;
  [childInsertTimer invalidate], childInsertTimer = nil;
  NSConnection *connection = [(NSDistantObject*)server connectionForProxy];
  [connection invalidate];
  server = nil;
}

#pragma mark -
#pragma mark Application Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
  NSNetServiceBrowser *myBrowser = [[NSNetServiceBrowser alloc] init];
  [myBrowser setDelegate:self];
  [myBrowser searchForServicesOfType:kServiceName inDomain:kDomainName];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender 
{
  [self disconnect];
  return NSTerminateNow;
}

#pragma mark -
#pragma mark NSNetServiceBrowser Delegate

- (void)netServiceBrowser:(NSNetServiceBrowser*)browser 
           didFindService:(NSNetService*)service 
               moreComing:(BOOL)more
{
  [service retain];
  [service setDelegate:self];
  [service resolveWithTimeout:5.0];
  [service startMonitoring];
  [browser stop];
  [browser release], browser = nil;
}

#pragma mark -
#pragma mark NetService delegate methods

- (void)netServiceDidResolveAddress:(NSNetService*)service
{
  NSConnection *clientConnection = nil;
  NSSocketPort *socket = nil;
  NSData *address = [[service addresses] lastObject];
  u_char family = ((struct sockaddr*)[address bytes])->sa_family;
  socket = [[NSSocketPort alloc] initRemoteWithProtocolFamily:family 
                                                   socketType:SOCK_STREAM 
                                                     protocol:IPPROTO_TCP 
                                                      address:address];
  clientConnection = [NSConnection connectionWithReceivePort:nil 
                                                    sendPort:socket];
  server = [clientConnection rootProxy];
  [socket release], socket = nil;
  [service stop];
  [service release];
  [self startTestTimers];
}

#pragma mark -
#pragma mark Start Test Timers

- (void)startTestTimers
{
  SEL selector = @selector(testPing);
  pingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                               target:self 
                                             selector:selector
                                             userInfo:nil 
                                              repeats:YES];
  selector = @selector(testObjectInsertion);
  insertTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:selector
                                               userInfo:nil 
                                                repeats:YES];
  selector = @selector(testObjectDeletion);
  deleteTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                 target:self 
                                               selector:selector
                                               userInfo:nil 
                                                repeats:YES];
  selector = @selector(testChildInsertion);
  childInsertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                      target:self 
                                                    selector:selector
                                                    userInfo:nil 
                                                     repeats:YES];
  selector = @selector(testChildDeletion);
  childDeleteTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                      target:self 
                                                    selector:selector
                                                    userInfo:nil 
                                                     repeats:YES];
  selector = @selector(testObjectFetch);
  fetchTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 
                                                target:self 
                                              selector:selector
                                              userInfo:nil 
                                               repeats:YES];
}

#pragma mark -
#pragma mark Test Methods

- (void)testPing
{
  [server ping];
}

- (void)testObjectFetch
{
  NSString *test = [GUID substringToIndex:3];
  NSPredicate *predicate = nil;
  predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", test];
  NSArray *results = [server objectsOfName:@"Test" withPredicate:predicate];
  NSEnumerator *enumerator = [results objectEnumerator];
  NSManagedObject *object;
  while (object = [enumerator nextObject]) {
    [object setValue:GUID forKey:@"name"];
  }
  [self setFilteredObjects:results];
}

- (void)testObjectInsertion
{
  if ((rand() % 2) == NO) return;
  NSManagedObject *object = [server createObject];
  [object setValue:GUID forKey:@"name"];
}

- (void)testObjectDeletion
{
  NSArray *objects = [server allObjects];
  
  if (![objects count]) return;

  int index = (rand() % [objects count]);
  NSManagedObject *toBeDeleted = [objects objectAtIndex:index];
  
  [server deleteObject:toBeDeleted];
}

- (void)testChildInsertion
{
  NSArray *objects = [server allObjects];
  id object = [objects objectAtIndex:(rand() % [objects count])];
  id child = [server createChildForObject:object];
  [child setValue:GUID forKey:@"name"];
}

- (void)testChildDeletion
{
  NSArray *objects = [server allObjects];

  int index = (rand() % [objects count]);
  id object = [objects objectAtIndex:index];

  NSSet *children = [object valueForKey:@"children"];
  
  if (![children count]) return;
  id child = [children anyObject];
  [server deleteObject:child];
}

@end
