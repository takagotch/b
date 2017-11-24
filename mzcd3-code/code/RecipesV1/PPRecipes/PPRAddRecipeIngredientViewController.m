/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRAddRecipeIngredientViewController.h"

#import "PPRTextEditViewController.h"
#import "PPRSelectIngredientTypeViewController.h"

@interface PPRAddRecipeIngredientViewController() <NSFetchedResultsControllerDelegate>

@end

@implementation PPRAddRecipeIngredientViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
  UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
  [[cell detailTextLabel] setText:[[[self recipeIngredientMO] valueForKey:@"quantity"] stringValue]];
  
  path = [NSIndexPath indexPathForRow:1 inSection:0];
  cell = [[self tableView] cellForRowAtIndexPath:path];
  [[cell textLabel] setText:[[self recipeIngredientMO] valueForKeyPath:@"name"]];
  
  path = [NSIndexPath indexPathForRow:2 inSection:0];
  cell = [[self tableView] cellForRowAtIndexPath:path];
  [[cell textLabel] setText:[[self recipeIngredientMO] valueForKeyPath:@"unitOfMeasure"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSString *identifier = [segue identifier];
  id viewController = [segue destinationViewController];
  
  if ([identifier isEqualToString:@"setQuantity"]) {
    [[viewController textField] setText:[[[self recipeIngredientMO] valueForKey:@"quantity"] stringValue]];
    
    [viewController setTextChangedBlock:^ BOOL (NSString *text, NSError **error) {
      NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
      
      NSNumber *quantity = [numberFormatter numberFromString:text];
      if (!quantity) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Invalid quantity" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"PragProg" code:1123 userInfo:dict];
        return NO;
      }
      
      NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
      UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
      [[cell detailTextLabel] setText:text];
      [[self recipeIngredientMO] setValue:quantity forKey:@"quantity"];
      
      return YES;
    }];
  } else if ([identifier isEqualToString:@"setType"]) {
    [[viewController textField] setText:[[self recipeIngredientMO] valueForKey:@"name"]];
    
    [viewController setTextChangedBlock:^ BOOL (NSString *text, NSError **error) {
      NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
      UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
      [[cell detailTextLabel] setText:text];
      [[self recipeIngredientMO] setValue:text forKey:@"name"];
      
      return YES;
    }];
  } else if ([identifier isEqualToString:@"setUnits"]) {
    [[viewController textField] setText:[[self recipeIngredientMO] valueForKey:@"unitOfMeasure"]];
    
    [viewController setTextChangedBlock:^ BOOL (NSString *text, NSError **error) {
      NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
      UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
      [[cell detailTextLabel] setText:text];
      [[self recipeIngredientMO] setValue:text forKey:@"unitOfMeasure"];
      
      return YES;
    }];
  }
}

- (IBAction)save:(id)sender;
{
  [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender;
{
  NSManagedObjectContext *moc = [[self recipeIngredientMO] managedObjectContext];
  [moc deleteObject:[self recipeIngredientMO]];
  [[self navigationController] popViewControllerAnimated:YES];
}

@end
