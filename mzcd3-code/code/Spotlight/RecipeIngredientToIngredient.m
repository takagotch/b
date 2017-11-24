/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "RecipeIngredientToIngredient.h"


@implementation RecipeIngredientToIngredient

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject*)source 
                                      entityMapping:(NSEntityMapping*)mapping 
                                            manager:(NSMigrationManager*)manager 
                                              error:(NSError**)error
{
  NSManagedObjectContext *destMOC = [manager destinationContext];
  NSString *destEntityName = [mapping destinationEntityName];
  
  //The name of the ingredient
  NSString *name = [source valueForKey:@"name"];
  
  NSMutableDictionary *userInfo = (NSMutableDictionary*)[manager userInfo];
  if (!userInfo) {
    userInfo = [NSMutableDictionary dictionary];
    [manager setUserInfo:userInfo];
  }
  NSMutableDictionary *ingredientLookup = [userInfo valueForKey:@"ingredients"];
  if (!ingredientLookup) {
    ingredientLookup = [NSMutableDictionary dictionary];
    [userInfo setValue:ingredientLookup forKey:@"ingredients"];
  }
  NSManagedObject *dest = [ingredientLookup valueForKey:name];
  if (!dest) {
    dest = [NSEntityDescription insertNewObjectForEntityForName:destEntityName
                                         inManagedObjectContext:destMOC];
    [dest setValue:name forKey:@"name"];
    [ingredientLookup setValue:dest forKey:name];
  }
  
  [manager associateSourceInstance:source
           withDestinationInstance:dest
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
