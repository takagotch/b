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
//  Created by Marcus Zarra on 9/22/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

#import "PPRDataController.h"

#define FAVORITE_METADATA_KEY @"FAVORITE_METADATA_KEY"

@interface PPRDataController()

@property (nonatomic, strong) NSManagedObjectContext *writerContext;
@property (nonatomic, copy) CompletionBlock completionBlock;

- (void)initializeCoreDataStack;
- (void)bulkUpdateFavorites;
- (void)deleteOldRecipes;
- (void)mergeExternalChanges:(NSArray*)objectIDArray ofType:(NSString*)type;
- (void)manuallyRefreshObjects:(NSArray*)objectIDArray;

@end

@implementation PPRDataController

- (instancetype)initWithCompletionBlock:(CompletionBlock)block;
{
  if (!(self = [super init])) return nil;
  
  [self setCompletionBlock:block];
  [self initializeCoreDataStack];
  
  return self;
}

- (void)initializeCoreDataStack
{
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PPRecipes" withExtension:@"momd"];
  ZAssert(modelURL, @"Failed to find model URL");
  
  NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
  
  [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
  [self setWriterContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
  [[self writerContext] setPersistentStoreCoordinator:psc];
  [[self managedObjectContext] setParentContext:[self writerContext]];
  
  dispatch_queue_t queue = NULL;
  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = nil;
    storeURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                    inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"PPRecipes.sqlite"];
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES]
               forKey:NSInferMappingModelAutomaticallyOption];
    NSError *error = nil;
    NSPersistentStore *store = nil;
    store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:storeURL
                                    options:options
                                      error:&error];
    if (!store) {
      ALog(@"Error adding persistent store to coordinator %@\n%@",
           [error localizedDescription], [error userInfo]);
    }
    
    NSDictionary *metadata = [store metadata];
    if (!metadata[FAVORITE_METADATA_KEY]) {
      [self bulkUpdateFavorites];
    }
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlockAndWait:^{
      NSError *error = nil;
      NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];
      NSInteger count = [moc countForFetchRequest:request error:&error];
      ZAssert(count != NSNotFound || !error, @"Failed to count type: %@\n%@", [error localizedDescription], [error userInfo]);
      
      if (count) return;
      
      NSArray *types = [[[NSBundle mainBundle] infoDictionary] objectForKey:ppRecipeTypes];
      
      for (NSString *recipeType in types) {
        NSManagedObject *typeMO = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:moc];
        [typeMO setValue:recipeType forKey:@"name"];
      }
      
      ZAssert([moc save:&error], @"Error saving moc: %@\n%@", [error localizedDescription], [error userInfo]);
    }];
    
    if ([self completionBlock]) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self completionBlock]();
      });
    }
  });
}

- (void)saveContext
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  [moc performBlockAndWait:^{
    if (![moc hasChanges]) return;
    
    NSError *error = nil;
    ZAssert([moc save:&error], @"Error saving MOC: %@\n%@",
            [error localizedDescription], [error userInfo]);
  }];
  
  NSManagedObjectContext *writer = [self writerContext];
  [writer performBlock:^{
    if (![writer hasChanges]) return;
    
    NSError *error = nil;
    ZAssert([writer save:&error], @"Error saving MOC: %@\n%@",
            [error localizedDescription], [error userInfo]);
  }];
}

- (NSDate*)dateFrom1YearAgo
{
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [NSDateComponents new];
  [components setMonth:-1];
  NSDate *date = [calendar dateByAddingComponents:components
                                           toDate:[NSDate date]
                                          options:0];

  return date;
}

- (NSDate*)dateFrom1MonthAgo
{
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [NSDateComponents new];
  [components setMonth:-1];
  NSDate *date = [calendar dateByAddingComponents:components
                                           toDate:[NSDate date]
                                          options:0];
  
  return date;
}

- (void)deleteOldRecipes
{
  NSManagedObjectContext *moc = [self writerContext];
  [moc performBlock:^{
    NSDate *yearOld = [self dateFrom1YearAgo];
    NSBatchDeleteRequest *request = nil;
    NSFetchRequest *fetch = nil;
    NSBatchDeleteResult *result = nil;
    NSPredicate *predicate = nil;
    NSError *error = nil;

    fetch = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    predicate = [NSPredicate predicateWithFormat:@"lastUsed <= %@", yearOld];
    [fetch setPredicate:predicate];
    request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetch];
    [request setResultType:NSBatchDeleteResultTypeObjectIDs];

    result = [moc executeRequest:request error:&error];
    if (!result) {
      ALog(@"Failed on bulk delete: %@\n%@",
           [error localizedDescription], [error userInfo]);
    }

    [self mergeExternalChanges:[result result] ofType:NSDeletedObjectsKey];
  }];
}

- (void)bulkUpdateFavorites
{
  NSManagedObjectContext *moc = [self writerContext];
  
  [moc performBlock:^{
    NSBatchUpdateRequest *request = nil;
    NSMutableDictionary *propertyChanges = nil;
    NSPredicate *pred = nil;
    NSBatchUpdateResult *result = nil;
    NSError *error = nil;

    request = [[NSBatchUpdateRequest alloc] initWithEntityName:@"Recipe"];
    
    NSDate *aMonthAgo = [self dateFrom1MonthAgo];
    pred = [NSPredicate predicateWithFormat:@"lastUsed >= %@", aMonthAgo];
    [request setPredicate:pred];
    
    propertyChanges = [NSMutableDictionary new];
    propertyChanges[@"favorite"] = @(YES);
    [request setPropertiesToUpdate:propertyChanges];
    [request setResultType:NSUpdatedObjectIDsResultType];
    
    result = [moc executeRequest:request error:&error];
    if (!result) {
      ALog(@"Failed to execute batch update: %@\n%@",
           [error localizedDescription], [error userInfo]);
    }

    //Notify the contexts of the changes
    [self mergeExternalChanges:[result result] ofType:NSUpdatedObjectsKey];

    NSMutableDictionary *metadata = nil;
    NSPersistentStore *store = nil;
    NSPersistentStoreCoordinator *coordinator = nil;

    //Update the store metadata
    coordinator = [[self writerContext] persistentStoreCoordinator];
    store = [[coordinator persistentStores] lastObject];
    metadata = [[store metadata] mutableCopy];
    [metadata setValue:@(YES) forKey:FAVORITE_METADATA_KEY];
    [store setMetadata:metadata];
  }];
}

- (void)manuallyRefreshObjects:(NSArray*)oIDArray;
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  [moc performBlockAndWait:^{
    [oIDArray enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID,
                                           NSUInteger index, BOOL *stop) {
      NSManagedObject *object = [moc objectRegisteredForID:objectID];
      if (!object || [object isFault]) return;
      [moc refreshObject:object mergeChanges:YES];
    }];
  }];
}

- (void)mergeExternalChanges:(NSArray*)oIDArray ofType:(NSString*)type
{
  NSDictionary *save = @{type : oIDArray};
  
  NSArray *contexts = @[[self managedObjectContext], [self writerContext]];
  
  [NSManagedObjectContext mergeChangesFromRemoteContextSave:save
                                               intoContexts:contexts];
}

@end
