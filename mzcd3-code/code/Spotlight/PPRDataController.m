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

@interface PPRDataController()

@property (nonatomic, copy) void (^initBlock)(void);

- (void)initializeCoreDataStack;

@end

@implementation PPRDataController

- (instancetype)init
{
  return [self initWithCompletion:NULL];
}

- (instancetype)initWithCompletion:(void(^)(void))block
{
  if (!(self = [super init])) return nil;

  [self setInitBlock:block];

  [self initializeCoreDataStack];

  return self;
}

- (void)saveContext
{
  NSManagedObjectContext *moc = [self managedObjectContext];

  if (!moc) return;
  if (![moc hasChanges]) return;

  NSError *error = nil;
  if (![moc save:&error]) {
    NSLog(@"Error saving MOC: %@\n%@", [error localizedDescription],
          [error userInfo]);
    abort();
  }
}

- (void)populateTypeEntities
{
  NSManagedObjectContext *moc = nil;
  NSManagedObjectContextConcurrencyType type = NSPrivateQueueConcurrencyType;
  moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
  [moc setParentContext:[self managedObjectContext]];
  [moc performBlockAndWait:^{
    NSFetchRequest *request = nil;
    request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];

    NSError *error = nil;
    NSArray *result = [moc executeFetchRequest:request
                                         error:&error];
    NSAssert(result != nil, [error localizedDescription]);
    if ([result count]) return;

    //The types table has not been populated
    NSArray *types;
    types = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"RecipeTypes"];

    for (NSString *type in types) {
      NSManagedObject *object = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Type"
                                 inManagedObjectContext:moc];
      [object setValue:type forKey:@"name"];
    }
    if (![moc save:&error]) {
      NSLog(@"Failed to populate type: %@\n%@",
            [error localizedDescription], [error userInfo]);
      abort();
    }
  }];
}

#pragma mark - Core Data stack

- (void)initializeCoreDataStack
{
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel"
                                            withExtension:@"momd"];
  NSAssert(modelURL != nil, @"Failed to find model URL");

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
      cloudURL = [cloudURL URLByAppendingPathComponent:@"PPRecipes"];
      [options setValue:[[NSBundle mainBundle] bundleIdentifier]
                 forKey:NSPersistentStoreUbiquitousContentNameKey];
      [options setValue:cloudURL
                 forKey:NSPersistentStoreUbiquitousContentURLKey];
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
      NSLog(@"Error adding persistent store to coordinator %@\n%@",
           [error localizedDescription], [error userInfo]);
      abort();
      //Present a user facing error
    }

    [self populateTypeEntities];

    if ([self initBlock]) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self initBlock]();
      });
    }
  });
}

@end
