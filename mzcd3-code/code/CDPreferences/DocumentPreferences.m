/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "DocumentPreferences.h"

@interface DocumentPreferences ()

- (NSManagedObject*)findParameter:(NSString*)key;
- (NSManagedObject*)createParameter:(NSString*)name;

@end

@implementation DocumentPreferences

- (id)initWithDocument:(NSPersistentDocument*)associatedDocument;
{
  if (!(self = [super init])) return nil;
  
  _associatedDocument = associatedDocument;
  
  return self;
}

- (id)valueForUndefinedKey:(NSString*)key
{
  id parameter = [self findParameter:key];
  if (!parameter && [[self defaults] objectForKey:key]) {
    return [[self defaults] objectForKey:key];
  }
  return [parameter valueForKey:@"value"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key
{
  [self willChangeValueForKey:key];
  NSManagedObject *parameter = [self findParameter:key];
  if (!parameter) {
    if ([[self defaults] valueForKey:key] && 
        [value isEqualTo:[[self defaults] valueForKey:key]]) {
      [self didChangeValueForKey:key];
      return;
    }
    parameter = [self createParameter:key];
  } else {
    if ([[self defaults] valueForKey:key] && 
        [value isEqualTo:[[self defaults] valueForKey:key]]) {
      [self willChangeValueForKey:key];
      NSManagedObjectContext *moc = nil;
      moc = [[self associatedDocument] managedObjectContext];
      [moc deleteObject:parameter];
      [self didChangeValueForKey:key];
      return;
    }
  }
  if ([value isKindOfClass:[NSNumber class]]) {
    [parameter setValue:[value stringValue] forKey:@"value"];
  } else if ([value isKindOfClass:[NSDate class]]) {
    [parameter setValue:[value description] forKey:@"value"];
  } else {
    [parameter setValue:value forKey:@"value"];
  }
  [self didChangeValueForKey:key];
}

- (NSManagedObject*)findParameter:(NSString*)name;
{
  NSManagedObjectContext *moc;
  NSManagedObject *param;
  NSError *error = nil;
  moc = [[self associatedDocument] managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"Parameter"
                                 inManagedObjectContext:moc]];
  NSPredicate *predicate = nil;
  predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
  [request setPredicate:predicate];
  
  param = [[moc executeFetchRequest:request error:&error] lastObject];
  if (error) {
    DLog(@"Error fetching parameter: %@\n%@", [error localizedDescription],
         [error userInfo]);
    return nil;
  }
  return param;
}

- (NSManagedObject*)createParameter:(NSString*)name
{
  NSManagedObject *param;
  NSManagedObjectContext *moc;
  moc = [[self associatedDocument] managedObjectContext];
  param = [NSEntityDescription insertNewObjectForEntityForName:@"Parameter"
                                        inManagedObjectContext:moc];
  [param setValue:name forKey:@"name"];
  return param;
}

- (NSArray*)allParameterNames;
{
  NSManagedObjectContext *moc;
  NSError *error = nil;
  moc = [[self associatedDocument] managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"Parameter"
                                 inManagedObjectContext:moc]];
  NSArray *params = [moc executeFetchRequest:request error:&error];
  if (error) {
    DLog(@"Error fetching parameter: %@\n%@", [error localizedDescription],
         [error userInfo]);
    return nil;
  }
  
  NSMutableArray *keys = [[[self defaults] allKeys] mutableCopy];
  for (NSManagedObject *param in params) {
    NSString *name = [param valueForKey:@"name"];
    [keys addObject:name];
  }
  return keys;
}

- (NSDictionary*)allParameters;
{
  NSManagedObjectContext *moc;
  NSError *error = nil;
  moc = [[self associatedDocument] managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"Parameter"
                                 inManagedObjectContext:moc]];
  NSArray *params = [moc executeFetchRequest:request error:&error];
  if (error) {
    DLog(@"Error fetching parameter: %@\n%@", [error localizedDescription],
         [error userInfo]);
    return nil;
  }
  NSMutableDictionary *dict = [[self defaults] mutableCopy];
  for (NSManagedObject *param in params) {
    NSString *name = [param valueForKey:@"name"];
    NSString *value = [param valueForKey:@"value"];
    [dict setValue: value forKey:name];
  }
  return dict;
}

@end
