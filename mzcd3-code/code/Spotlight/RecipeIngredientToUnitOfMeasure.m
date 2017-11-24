/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "RecipeIngredientToUnitOfMeasure.h"

@implementation RecipeIngredientToUnitOfMeasure

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject*)source 
                                      entityMapping:(NSEntityMapping*)mapping 
                                            manager:(NSMigrationManager*)manager 
                                              error:(NSError**)error
{
  NSManagedObjectContext *destMOC = [manager destinationContext];
  NSString *destEntityName = [mapping destinationEntityName];
  
  //The unit of measure
  NSString *unit = [source valueForKey:@"unitOfMeasure"];
  
  NSMutableDictionary *userInfo = (NSMutableDictionary*)[manager userInfo];
  if (!userInfo) {
    userInfo = [NSMutableDictionary dictionary];
    [manager setUserInfo:userInfo];
  }
  NSMutableDictionary *unitLookup = [userInfo valueForKey:@"units"];
  if (!unitLookup) {
    unitLookup = [NSMutableDictionary dictionary];
    [userInfo setValue:unitLookup forKey:@"units"];
  }
  NSManagedObject *unitMO = [unitLookup valueForKey:unit];
  if (!unitMO) {
    unitMO = [NSEntityDescription insertNewObjectForEntityForName:destEntityName
                                           inManagedObjectContext:destMOC];
    [unitMO setValue:unit forKey:@"name"];
    [unitLookup setValue:unitMO forKey:unit];
  }
  
  [manager associateSourceInstance:source
           withDestinationInstance:unitMO
                  forEntityMapping:mapping];
  
  return YES;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject*)dInstance 
                                    entityMapping:(NSEntityMapping*)mapping 
                                          manager:(NSMigrationManager*)manager 
                                            error:(NSError**)error
{
  return YES;
}

@end
