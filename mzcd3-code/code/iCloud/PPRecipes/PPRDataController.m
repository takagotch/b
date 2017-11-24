/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
//
//  PPRDataController.m
//  PPRecipes
//
//  Created by Marcus S. Zarra on 10/15/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

#import "PPRDataController.h"

#define EVENTS_ARRAY @[UIApplicationDidEnterBackgroundNotification, \
                       UIApplicationWillResignActiveNotification, \
                       UIApplicationWillTerminateNotification]

@interface PPRDataController()

@property (nonatomic, copy) void (^initBlock)(void);

- (void)initializeCoreDataStack;
- (void)initializeDocument;

@end

@implementation PPRDataController

- (instancetype)initWithCompletion:(void(^)(void))block
{
  if (!(self = [super init])) return nil;

  [self setInitBlock:block];

  [self initializeCoreDataStack];

  for (id event in EVENTS_ARRAY) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveContext)
                                                 name:event
                                               object:nil];
  }

  return self;
}

- (void)saveContext
{
  if ([self managedDocument]) {
    NSURL *fileURL = [[self managedDocument] fileURL];
    [[self managedDocument] saveToURL:fileURL
                     forSaveOperation:UIDocumentSaveForCreating
                    completionHandler:^(BOOL success) {
                      //Handle failure
                    }];
    return;
  }

  NSManagedObjectContext *moc = [self managedObjectContext];

  if (!moc) return;
  if (![moc hasChanges]) return;

  NSError *error = nil;
  ZAssert([moc save:&error], @"Error saving MOC: %@\n%@", [error localizedDescription], [error userInfo]);
}


- (void)documentStateChanged:(NSNotification*)notification
{
  switch ([[notification object] documentState]) {
    case UIDocumentStateNormal:
      DLog(@"UIDocumentStateNormal");
      break;
    case UIDocumentStateClosed:
      DLog(@"UIDocumentStateClosed %@", notification);
      break;
    case UIDocumentStateInConflict:
      DLog(@"UIDocumentStateInConflict %@", notification);
      break;
    case UIDocumentStateSavingError:
      DLog(@"UIDocumentStateSavingError %@", notification);
      break;
    case UIDocumentStateEditingDisabled:
      DLog(@"UIDocumentStateEditingDisabled %@", notification);
      break;
    case UIDocumentStateProgressAvailable:
      DLog(@"UIDocumentStateProgressAvailable %@", notification);
      break;
  }
}

- (void)mergePSCChanges:(NSNotification*)notification
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  [moc performBlock:^{
    [moc mergeChangesFromContextDidSaveNotification:notification];
  }];
}

#pragma mark - Core Data stack

- (void)initializeDocument
{
  dispatch_queue_t queue;
  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

  dispatch_async(queue, ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = nil;
    storeURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                    inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"PPRecipes"];

    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];

    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSInferMappingModelAutomaticallyOption];

    if (cloudURL) {
      cloudURL = [cloudURL URLByAppendingPathComponent:@"PPRecipes"];

      [options setValue:[[NSBundle mainBundle] bundleIdentifier]
                 forKey:NSPersistentStoreUbiquitousContentNameKey];
      [options setValue:cloudURL
                 forKey:NSPersistentStoreUbiquitousContentURLKey];
    }

    UIManagedDocument *document = nil;
    document = [[UIManagedDocument alloc] initWithFileURL:storeURL];
    [document setPersistentStoreOptions:options];

    NSMergePolicy *policy = [[NSMergePolicy alloc] initWithMergeType:
                             NSMergeByPropertyObjectTrumpMergePolicyType];
    [[document managedObjectContext] setMergePolicy:policy];

    void (^completion)(BOOL) = ^(BOOL success) {
      if (!success) {
        ALog(@"Error saving %@\n%@", storeURL, [document debugDescription]);
        return;
      }


      if ([self initBlock]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
          [self initBlock]();
        });
      }
    };

    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
      [document openWithCompletionHandler:completion];
      return;
    }

    [document saveToURL:storeURL
       forSaveOperation:UIDocumentSaveForCreating
      completionHandler:completion];
    [self setManagedDocument:document];
  });
}

- (void)initializeCoreDataStack
{
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PPRecipes"
                                            withExtension:@"momd"];
  ZAssert(modelURL, @"Failed to find model URL");

  NSManagedObjectModel *mom = nil;
  mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

  NSPersistentStoreCoordinator *psc = nil;
  psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

  NSManagedObjectContext *moc = nil;
  NSUInteger type = NSMainQueueConcurrencyType;
  moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
  [moc setPersistentStoreCoordinator:psc];

  [self setManagedObjectContext:moc];

  dispatch_queue_t queue;
  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSInferMappingModelAutomaticallyOption];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (cloudURL) {
      DLog(@"iCloud enabled: %@", cloudURL);
      cloudURL = [cloudURL URLByAppendingPathComponent:@"PPRecipes"];
      [options setValue:[[NSBundle mainBundle] bundleIdentifier]
                 forKey:NSPersistentStoreUbiquitousContentNameKey];
      [options setValue:cloudURL
                 forKey:NSPersistentStoreUbiquitousContentURLKey];
    } else {
      DLog(@"iCloud is not enabled");
    }
    NSURL *sURL = nil;
    sURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                inDomains:NSUserDomainMask] lastObject];
    sURL = [sURL URLByAppendingPathComponent:@"PPRecipes-iCloud.sqlite"];
    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = nil;
    coordinator = [[self managedObjectContext] persistentStoreCoordinator];
    NSPersistentStore *store = nil;




    
    store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:sURL
                                            options:options
                                              error:&error];
    if (!store) {
      ALog(@"Error adding persistent store to coordinator %@\n%@",
           [error localizedDescription], [error userInfo]);
      //Present a user facing error
    }
    if ([self initBlock]) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self initBlock]();
      });
    }
  });
}

- (void)initializeCoreDataStackV2
{
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PPRecipes"
                                            withExtension:@"momd"];
  ZAssert(modelURL, @"Failed to find model URL");

  NSManagedObjectModel *mom = nil;
  mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  ZAssert(mom, @"Failed to initialize model");

  NSPersistentStoreCoordinator *psc = nil;
  psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
  ZAssert(psc, @"Failed to initialize persistent store coordinator");

  NSManagedObjectContext *moc = nil;
  moc = [NSManagedObjectContext alloc];
  moc = [moc initWithConcurrencyType:NSMainQueueConcurrencyType];
  [moc setPersistentStoreCoordinator:psc];

  [self setManagedObjectContext:moc];

  dispatch_queue_t queue;
  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSInferMappingModelAutomaticallyOption];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *docURL = nil;
    docURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                  inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = nil;

    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = nil;
    coordinator = [[self managedObjectContext] persistentStoreCoordinator];
    NSPersistentStore *store = nil;

    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (!cloudURL) {
      storeURL = [docURL URLByAppendingPathComponent:@"PPRecipes.sqlite"];
      store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:storeURL
                                              options:options
                                                error:&error];
      if (!store) {
        ALog(@"Error adding persistent store to coordinator %@\n%@",
             [error localizedDescription], [error userInfo]);
        //Present a user facing error
        return;
      }
      if ([self initBlock]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
          [self initBlock]();
        });
      }
      return;
    }
    storeURL = [docURL URLByAppendingPathComponent:@"PPRecipes-iCloud.sqlite"];
    NSURL *oldURL = nil;
    oldURL = [docURL URLByAppendingPathComponent:@"PPRecipes.sqlite"];
    if ([fileManager fileExistsAtPath:[oldURL path]]) {
      store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:oldURL
                                              options:options
                                                error:&error];
      if (!store) {
        ALog(@"Error adding OLD persistent store to coordinator %@\n%@",
             [error localizedDescription], [error userInfo]);
        //Present a user facing error
        return;
      }
    }
    cloudURL = [cloudURL URLByAppendingPathComponent:@"PPRecipes"];
    [options setValue:[[NSBundle mainBundle] bundleIdentifier]
               forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setValue:cloudURL
               forKey:NSPersistentStoreUbiquitousContentURLKey];
    store = [coordinator migratePersistentStore:store
                                          toURL:storeURL
                                        options:options
                                       withType:NSSQLiteStoreType
                                          error:&error];
    if (!store) {
      ALog(@"Error adding OLD persistent store to coordinator %@\n%@",
           [error localizedDescription], [error userInfo]);
      //Present a user facing error
      return;
    }

    ZAssert([fileManager removeItemAtURL:oldURL error:&error],
            @"Failed to remove old persistent store at %@\n%@\n%@",
            oldURL, [error localizedDescription], [error userInfo]);

    if ([self initBlock]) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self initBlock]();
      });
    }
  });
}


@end
