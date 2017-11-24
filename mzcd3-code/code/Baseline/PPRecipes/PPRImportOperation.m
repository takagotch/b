/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRImportOperation.h"

@interface PPRImportOperation()

@property (nonatomic, strong) NSData *incomingData;

- (void)populateManagedObject:(NSManagedObject*)mo 
               fromDictionary:(NSDictionary*)dict;

@end

@implementation PPRImportOperation

- (id)initWithData:(NSData*)data
{
  if (!(self = [super init])) return nil;
  
  [self setIncomingData:data];
  
  return self;
}

- (void)processRecipeIntoContext:(NSManagedObjectContext*)moc
{
  NSError *error = nil;
  id recipesJSON = nil;
  recipesJSON = [NSJSONSerialization JSONObjectWithData:[self incomingData]
                                                options:0
                                                  error:&error];
  if (!recipesJSON) {
    [self importBlock](NO, error);
    return;
  }

  NSManagedObject *recipeMO = nil;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipe"
                                            inManagedObjectContext:moc];

  if ([recipesJSON isKindOfClass:[NSDictionary class]]) {
    recipeMO = [[NSManagedObject alloc] initWithEntity:entity
                        insertIntoManagedObjectContext:moc];

    [self populateManagedObject:recipeMO fromDictionary:recipesJSON];
    return;
  } else {
    NSAssert([recipesJSON isKindOfClass:[NSArray class]],
             @"Unknown structure root: %@", [recipesJSON class]);
    for (id recipeDict in recipesJSON) {
      NSAssert([recipeDict isKindOfClass:[NSDictionary class]],
               @"Unknown recipe structure: %@", [recipeDict class]);
      recipeMO = [[NSManagedObject alloc] initWithEntity:entity
                          insertIntoManagedObjectContext:moc];

      [self populateManagedObject:recipeMO fromDictionary:recipeDict];
    }

    if (![moc save:&error]) {
      NSLog(@"Error saving context: %@\n%@", [error localizedDescription],
            [error userInfo]);
      abort();
    }
  }
}

- (void)main
{
  NSManagedObjectContext *localMOC = nil;
  NSUInteger type = NSPrivateQueueConcurrencyType;
  localMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
  [localMOC setParentContext:[self mainContext]];

  [localMOC performBlockAndWait:^{
    [self processRecipeIntoContext:localMOC];
  }];
}

- (void)populateManagedObject:(NSManagedObject*)mo 
               fromDictionary:(NSDictionary*)dict
{
  NSManagedObjectContext *context = [mo managedObjectContext];
  NSEntityDescription *entity = [mo entity];
  NSArray *attKeys = [[entity attributesByName] allKeys];
  NSDictionary *atttributesDict = [dict dictionaryWithValuesForKeys:attKeys];
  [mo setValuesForKeysWithDictionary:atttributesDict];
  
  NSManagedObject* (^createChild)(NSDictionary *childDict, 
                                  NSEntityDescription *destEntity, 
                                  NSManagedObjectContext *context);
  createChild = ^(NSDictionary *childDict, NSEntityDescription *destEntity, 
                  NSManagedObjectContext *context) {
    NSManagedObject *destMO = nil;
    destMO = [[NSManagedObject alloc] initWithEntity:destEntity
                      insertIntoManagedObjectContext:context];
    [self populateManagedObject:destMO fromDictionary:childDict];
    return destMO;
  };

  
  NSDictionary *relationshipsByName = [entity relationshipsByName];
  NSManagedObject *destMO = nil;
  
  for (NSString *key in relationshipsByName) {
    id childStructure = [dict valueForKey:key];
    if (!childStructure) continue; //Relationship not populated
    NSRelationshipDescription *relDesc nil;
	relDesc = [relationshipsByName valueForKey:key];
    NSEntityDescription *destEntity = [relDesc destinationEntity];
    
    if (![relDesc isToMany]) { //ToOne
      destMO = createChild(childStructure, destEntity, context);
      [mo setValue:destMO forKey:key];
      continue;
    }
    
    NSMutableSet *childSet = [NSMutableSet set];
    for (NSDictionary *childDict in childStructure) {
      destMO = createChild(childDict, destEntity, context);
      [childSet addObject:destMO];
    }
    [self setValue:childSet forKey:key];
  }
}

@end
