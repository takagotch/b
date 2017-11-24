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

@interface PPRAppDelegate()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSURL *fileToOpenURL;

- (void)initializeCoreDataStack;
- (void)contextInitialized;

- (void)consumeIncomingFileURL:(NSURL*)url;

@end

@implementation PPRAppDelegate

@synthesize window;
@synthesize managedObjectContext;
@synthesize fileToOpenURL;

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self initializeCoreDataStack];
  
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
  
  [controller setManagedObjectContext:[self managedObjectContext]];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [self saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [self saveContext];
}

- (void)saveContext
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  
  if (!moc) return;
  if (![moc hasChanges]) return;
  
  NSError *error = nil;
  ZAssert([moc save:&error], @"Error saving MOC: %@\n%@", [error localizedDescription], [error userInfo]);
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
  if ([self managedObjectContext]) {
    [self consumeIncomingFileURL:url];
  } else {
    [self setFileToOpenURL:url];
  }
  return YES;
}

#pragma mark - Core Data stack

- (void)initializeCoreDataStack
{
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PPRecipes" withExtension:@"momd"];
  ZAssert(modelURL, @"Failed to find model URL");
  
  NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  ZAssert(mom, @"Failed to initialize model");
  
  NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
  ZAssert(psc, @"Failed to initialize persistent store coordinator");
  
  NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  [moc setPersistentStoreCoordinator:psc];
  
  [self setManagedObjectContext:moc];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"PPRecipes.sqlite"];
    
    NSPersistentStoreCoordinator *coordinator = [moc persistentStoreCoordinator];
    
    NSError *error = nil;
    if (![self progressivelyMigrateURL:storeURL
                                ofType:NSXMLStoreType
                               toModel:[coordinator managedObjectModel]
                                 error:&error]) {
      ALog(@"Error performing migration: %@\n%@", [error localizedDescription],
           [error userInfo]);
      return;
    }
    
    NSError *error = nil;
    
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (!store) {
      ALog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
      //Present a user facing error
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];
    
    [moc performBlockAndWait:^{
      NSError *error = nil;
      NSInteger count = [[self managedObjectContext] countForFetchRequest:request error:&error];
      ZAssert(count != NSNotFound || !error, @"Failed to count type: %@\n%@", [error localizedDescription], [error userInfo]);
      
      if (count) return;
      
      NSArray *types = [[[NSBundle mainBundle] infoDictionary] objectForKey:ppRecipeTypes];
      
      for (NSString *recipeType in types) {
        NSManagedObject *typeMO = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:moc];
        [typeMO setValue:recipeType forKey:@"name"];
      }
      
      ZAssert([moc save:&error], @"Error saving moc: %@\n%@", [error localizedDescription], [error userInfo]);
    }];
    
    [self contextInitialized];
  });
}

#pragma mark - Progressive Migration -

- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL
                         ofType:(NSString*)type
                        toModel:(NSManagedObjectModel*)finalModel
                          error:(NSError**)error
{
  NSDictionary *sourceMetadata =
  [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                             URL:sourceStoreURL
                                                           error:error];
  if (!sourceMetadata) return NO;
  if ([finalModel isConfiguration:nil
      compatibleWithStoreMetadata:sourceMetadata]) {
    *error = nil;
    return YES;
  }
  //Find the source model
  NSManagedObjectModel *sourceModel = [NSManagedObjectModel
                                       mergedModelFromBundles:nil
                                       forStoreMetadata:sourceMetadata];
  NSAssert(sourceModel != nil, ([NSString stringWithFormat:
                                 @"Failed to find source model\n%@",
                                 sourceMetadata]));
  //Find all of the mom and momd files in the Resources directory
  NSMutableArray *modelPaths = [NSMutableArray array];
  NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                          inDirectory:nil];
  for (NSString *momdPath in momdArray) {
    NSString *resourceSubpath = [momdPath lastPathComponent];
    NSArray *array = [[NSBundle mainBundle]
                      pathsForResourcesOfType:@"mom"
                      inDirectory:resourceSubpath];
    [modelPaths addObjectsFromArray:array];
  }
  NSArray* otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                            inDirectory:nil];
  [modelPaths addObjectsFromArray:otherModels];
  if (!modelPaths || ![modelPaths count]) {
    //Throw an error if there are no models
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"No models found in bundle"
            forKey:NSLocalizedDescriptionKey];
    //Populate the error
    *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dict];
    return NO;
  }
  
  //See if we can find a matching destination model
  NSMappingModel *mappingModel = nil;
  NSManagedObjectModel *targetModel = nil;
  NSString *modelPath = nil;
  for (modelPath in modelPaths) {
    targetModel = [[NSManagedObjectModel alloc]
                   initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                            forSourceModel:sourceModel
                                          destinationModel:targetModel];
    //If we found a mapping model then proceed
    if (mappingModel) break;
    //Release the target model and keep looking
    [targetModel release], targetModel = nil;
  }
  //We have tested every model, if nil here we failed
  if (!mappingModel) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"No models found in bundle"
            forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"Zarra"
                                 code:8001
                             userInfo:dict];
    return NO;
  }
  //We have a mapping model and a destination model.  Time to migrate
  NSMigrationManager *manager = [[NSMigrationManager alloc]
                                 initWithSourceModel:sourceModel
                                 destinationModel:targetModel];
  NSString *modelName = [[modelPath lastPathComponent]
                         stringByDeletingPathExtension];
  NSString *storeExtension = [[sourceStoreURL path] pathExtension];
  NSString *storePath = [[sourceStoreURL path] stringByDeletingPathExtension];
  //Build a path to write the new store
  storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath,
               modelName, storeExtension];
  NSURL *destinationStoreURL = [NSURL fileURLWithPath:storePath];
  if (![manager migrateStoreFromURL:sourceStoreURL
                               type:type
                            options:nil
                   withMappingModel:mappingModel
                   toDestinationURL:destinationStoreURL
                    destinationType:type
                 destinationOptions:nil
                              error:error]) {
    return NO;
  }
  //Migration was successful, move the files around to preserve the source
  NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
  guid = [guid stringByAppendingPathExtension:modelName];
  guid = [guid stringByAppendingPathExtension:storeExtension];
  NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
  NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager moveItemAtPath:[sourceStoreURL path]
                            toPath:backupPath
                             error:error]) {
    //Failed to copy the file
    return NO;
  }
  //Move the destination to the source path
  if (![fileManager moveItemAtPath:storePath
                            toPath:[sourceStoreURL path]
                             error:error]) {
    //Try to back out the source move first, no point in checking it for errors
    [fileManager moveItemAtPath:backupPath
                         toPath:[sourceStoreURL path]
                          error:nil];
    return NO;
  }
  //We may not be at the "current" model yet, so recurse
  return [self progressivelyMigrateURL:sourceStoreURL
                                ofType:type
                               toModel:finalModel
                                 error:error];
}

#pragma mark - Import Handling

- (void)consumeIncomingFileURL:(NSURL*)url;
{
  NSData *data = [NSData dataWithContentsOfURL:url];
  PPRImportOperation *op = [[PPRImportOperation alloc] initWithData:data];
  [op setMainContext:[self managedObjectContext]];
  [op setCompletionBlock:^(BOOL success, NSError *error) {
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
