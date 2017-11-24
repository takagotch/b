/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRAppDelegate.h"

#import "PPRMasterViewController.h"
#import "PPRDataController.h"

@interface PPRAppDelegate()

- (void)contextInitialized;

@end

@implementation PPRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self setDataController:[[PPRDataController alloc] initWithCompletion:^{
    [self contextInitialized];
  }]];

  id controller = nil;
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    id splitViewController = [[self window] rootViewController];
    UINavigationController *navigationController = [[splitViewController viewControllers] lastObject];
    [splitViewController setDelegate:[navigationController topViewController]];
    
    UINavigationController *masterNavigationController = [[splitViewController viewControllers] objectAtIndex:0];
    controller = [masterNavigationController topViewController];
  } else {
    id navigationController = [[self window] rootViewController];
    controller = [navigationController topViewController];
  }
  
  [controller setDataController:[self dataController]];
  
  return YES;
}

- (void)contextInitialized;
{
  DLog(@"fired");
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(documentStateChanged:)
                 name:UIDocumentStateChangedNotification
               object:[[self dataController] managedDocument]];

  NSString *name = nil;
  name = NSPersistentStoreDidImportUbiquitousContentChangesNotification;
  NSManagedObjectContext *moc = [[self dataController] managedObjectContext];
  [center addObserver:self
             selector:@selector(mergePSCChanges:)
                 name:name
               object:[moc persistentStoreCoordinator]];
}

@end
