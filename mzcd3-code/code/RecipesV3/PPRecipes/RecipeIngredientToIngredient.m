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

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject*)src 
                                      entityMapping:(NSEntityMapping*)map 
                                            manager:(NSMigrationManager*)mgr
                                              error:(NSError**)error
{
  NSManagedObjectContext *destMOC = [mgr destinationContext];
  NSString *deName = [map destinationEntityName];

  NSString *name = [src valueForKey:@"name"];
  
  NSMutableDictionary *ui = (NSMutableDictionary*)[mgr userInfo];
  if (!ui) {
    ui = [NSMutableDictionary dictionary];
    [mgr setUserInfo:ui];
  }
  NSMutableDictionary *inLookup = [ui valueForKey:@"ingredients"];
  if (!inLookup) {
    inLookup = [NSMutableDictionary dictionary];
    [ui setValue:inLookup forKey:@"ingredients"];
  }
  
  NSMutableDictionary *uofmLookup = [ui valueForKey:@"unitOfMeasure"];
  if (!uofmLookup) {
    uofmLookup = [NSMutableDictionary dictionary];
    [ui setValue:uofmLookup forKey:@"unitOfMeasure"];
  }
  

  NSManagedObject *dest = [ingredientLookup valueForKey:name];
  if (!dest) {
    dest = [NSEntityDescription insertNewObjectForEntityForName:deName
                                         inManagedObjectContext:destMOC];
    [dest setValue:name forKey:@"name"];
    [inLookup setValue:dest forKey:name];
    
    name = [source valueForKey:@"unitOfMeasure"];
    NSManagedObject *uofm = [uofmLookup valueForKey:name];
    if (!uofm) {
      id entityName = @"UnitOfMeasure";
      uofm = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                           inManagedObjectContext:destMOC];
      [uofm setValue:name forKey:@"name"];
      [dest setValue:uofm forKey:@"unitOfMeasure"];
      [uofmLookup setValue:uofm forKey:name];
    }
  }

  [manager associateSourceInstance:source
           withDestinationInstance:dest
                  forEntityMapping:mapping];
  return YES;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject*)dIn 
                                    entityMapping:(NSEntityMapping*)map 
                                          manager:(NSMigrationManager*)mgr 
                                            error:(NSError**)error
{
  return YES;
}

@end
