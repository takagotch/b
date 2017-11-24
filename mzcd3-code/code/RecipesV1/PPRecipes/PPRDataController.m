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
//  Created by Marcus S. Zarra on 7/11/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

#import "PPRDataController.h"

@interface PPRDataController()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong) NSManagedObjectContext *writerContext;
@property (copy) InitCallbackBlock initCallback;

@end

@implementation PPRDataController

- (id)initWithCallback:(InitCallbackBlock)callback;
{
  if (!(self = [super init])) return nil;
  
  [self setInitCallback:callback];
  [self initializeCoreData];
  
  return self;
}

- (void)save
{
}

- (void)initializeCoreData;
{
  if ([self managedObjectContext]) return;
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PPRecipes"
                                            withExtension:@"momd"];
  NSAssert(modelURL != nil, @"Failed to locate momd in app bundle");
  NSManagedObjectModel *mom = nil;
  mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  NSPersistentStoreCoordinator *psc = nil;
  psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

  NSManagedObjectContext *moc = nil;
  moc = [NSManagedObjectContext alloc];
  moc = [moc initWithConcurrencyType:NSMainQueueConcurrencyType];
  [self setManagedObjectContext:moc];
  [moc setPersistentStoreCoordinator:psc];

  dispatch_queue_t queue;
  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
  dispatch_async(queue, ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory
                                       inDomains:NSUserDomainMask];
    NSURL *documentsURL = [urls lastObject];
    NSURL *storeURL = nil;
    storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    NSError *error = nil;
    NSPersistentStore *store = nil;
    store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:storeURL
                                    options:nil
                                      error:&error];
    if (!store) {
      NSLog(@"Error initializing PSC: %@\n%@", [error localizedDescription],
            [error userInfo]);
    }

    if (![self initCallback]) return;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self initCallback]();
    });
  });
}


@end
