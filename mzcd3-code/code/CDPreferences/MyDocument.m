/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "MyDocument.h"
#import "DocumentPreferences.h"

@implementation MyDocument

@synthesize preferences;

- (id)init 
{
  if (!(self = [super init])) return nil;
  
  [self setPreferences:[[DocumentPreferences alloc] initWithDocument:self]];
  
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults setValue:[NSNumber numberWithBool:YES] forKey:@"default1"];
  [defaults setValue:@"DefaultValue2" forKey:@"default2"];
  [defaults setValue:@"DefaultValue3" forKey:@"default3"];
  [[self preferences] setDefaults:defaults];
  
  return self;
}

- (NSString *)windowNibName 
{
  return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
  [super windowControllerDidLoadNib:windowController];
  // user interface preparation code
  
  [self managedObjectContext];
  
  if ([[[self preferences] valueForKey:@"default1"] boolValue]) {
    //Do something clever
  }
  [[self preferences] setValue:@"New Value" forKey:@"newKey"];
}

- (void)clunkyParameterAccess
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"parameter"
                                 inManagedObjectContext:moc]];
  [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", 
                         @"default1"]];
  NSError *error = nil;
  NSManagedObject *param = [[moc executeFetchRequest:request 
                                               error:&error] lastObject];
  if (error) {
    DLog(@"Error fetching param: %@\n%@", [error localizedDescription],
         [error userInfo]);
    return;
  }
  
  NSLog(@"Parameter value %@", [param valueForKey:@"value"]);
}

- (void)clunkyParameterWrite
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"parameter"
                                 inManagedObjectContext:moc]];
  
  [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", 
                         @"default1"]];
  
  NSError *error = nil;
  NSManagedObject *param = [[moc executeFetchRequest:request 
                                               error:&error] lastObject];
  if (error) {
    DLog(@"Error fetching param: %@\n%@", [error localizedDescription],
         [error userInfo]);
    return;
  }
  if (!param) {
    param = [NSEntityDescription insertNewObjectForEntityForName:@"Parameter"
                                          inManagedObjectContext:moc];
    [param setValue:@"default1" forKey:@"name"];
  }
  [param setValue:@"SomeValue" forKey:@"value"];
}

@end
