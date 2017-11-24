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
#import "PPRImportOperation.h"
#import "PPRDataController.h"

@interface PPRAppDelegate()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSURL *fileToOpenURL;

- (void)contextInitialized;

- (void)consumeIncomingFileURL:(NSURL*)url;

@end

@implementation PPRAppDelegate

@synthesize window;
@synthesize managedObjectContext;
@synthesize fileToOpenURL;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self setDataController:[[PPRDataController alloc] initWithCompletionBlock:^{
    [self contextInitialized];
  }]];
  
  id controller = nil;
  
  UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
  if (idiom == UIUserInterfaceIdiomPad) {
    id splitViewController = [[self window] rootViewController];
    UINavigationController *navigationController = nil;
    navigationController = [[splitViewController viewControllers] lastObject];
    [splitViewController setDelegate:[navigationController topViewController]];
    
    UINavigationController *masterNC = nil;
    masterNC = [[splitViewController viewControllers] objectAtIndex:0];
    controller = [masterNC topViewController];
  } else {
    id navigationController = [[self window] rootViewController];
    controller = [navigationController topViewController];
  }
  
  [controller setManagedObjectContext:[[self dataController] managedObjectContext]];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  [[self dataController] saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[self dataController] saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[self dataController] saveContext];
}

- (void)contextInitialized;
{
  //Finish UI initialization
  if (![self fileToOpenURL]) return;
  [self consumeIncomingFileURL:[self fileToOpenURL]];
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation
{
  if ([self dataController]) {
    [self consumeIncomingFileURL:url];
  } else {
    [self setFileToOpenURL:url];
  }
  return YES;
}

#pragma mark - Core Data stack

#pragma mark - Import Handling

- (void)consumeIncomingFileURL:(NSURL*)url;
{
  NSData *data = [NSData dataWithContentsOfURL:url];
  PPRImportOperation *op = [[PPRImportOperation alloc] initWithData:data];
  [op setMainContext:[self managedObjectContext]];
  [op setImportBlock:^(BOOL success, NSError *error) {
    if (success) {
      //Clear visual feedback
    } else {
      //Present an error to the user
    }
  }];
  [[NSOperationQueue mainQueue] addOperation:op];
  
  //Give visual feedback of the import
}

@end
