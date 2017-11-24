/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPREditRecipeViewController.h"

#import "PPRTextEditViewController.h"
#import "PPRSelectTypeViewController.h"
#import "PPRSetDateViewController.h"
#import "PPRSelectAuthorViewController.h"

@interface PPREditRecipeViewController ()

- (void)populateTableData;

@end

@implementation PPREditRecipeViewController

@synthesize recipeMO;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
  } else {
    return YES;
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [self populateTableData];
  } else {
    //Populate the iPad view
  }
}

- (void)populateTableData
{
  UITableView *table = [self tableView];
  
  NSInteger index = 0;
  NSIndexPath *path = nil;
  UITableViewCell *cell = nil;
  id temp = nil;
  
  while (index <= 6) {
    path = [NSIndexPath indexPathForRow:index inSection:0];
    cell = [table cellForRowAtIndexPath:path];
    switch (index) {
      case 0: //Name
        [[cell detailTextLabel] setText:[[self recipeMO] valueForKey:@"name"]];
        break;
      case 1: //Type
        [[cell detailTextLabel] setText:[[self recipeMO] valueForKey:@"type"]];
        break;
      case 2: //Serves
        [[cell detailTextLabel] setText:[[[self recipeMO] valueForKey:@"serves"] stringValue]];
        break;
      case 3: //lastUsed
        [[cell detailTextLabel] setText:[[self recipeMO] lastUsedString]];
        break;
      case 4: //Author
        [[cell detailTextLabel] setText:[[self recipeMO] valueForKeyPath:@"author.name"]];
        break;
      case 5: //description
        temp = [cell viewWithTag:1123];
        [temp setText:[[self recipeMO] valueForKey:@"desc"]];
        break;
      case 6: //ingredients
        temp = [[self recipeMO] valueForKey:@"ingredients"];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [temp count]]];
        break;
      default:
        ALog(@"Bad index: %i", index);
    }
    ++index;
  }
}

- (IBAction)save:(id)sender;
{
  NSError *error = nil;
  NSManagedObjectContext *moc = [[self recipeMO] managedObjectContext];
  ZAssert([moc save:&error], @"Error saving moc: %@\n%@", 
          [error localizedDescription], [error userInfo]);
  
  [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender;
{
  NSManagedObjectContext *moc = [[self recipeMO] managedObjectContext];
  if ([[self recipeMO] isInserted]) {
    [moc deleteObject:[self recipeMO]];
  } else {
    [moc refreshObject:[self recipeMO] mergeChanges:NO];
  }
  
  [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Segue handlers

- (void)prepareForEditRecipeNameSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  id editRecipeNameViewController = [segue destinationViewController];
  [[editRecipeNameViewController textField] setText:[[self recipeMO] valueForKey:@"name"]];
  
  BOOL (^changedText)(NSString *text, NSError **error) = ^(NSString *text, NSError **error) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[cell detailTextLabel] setText:text];
    [[self recipeMO] setValue:text forKey:@"name"];
    
    return YES;
  };
  
  [editRecipeNameViewController setTextChangedBlock:changedText];
}

- (void)prepareForSelectTypeSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  id viewController = [segue destinationViewController];
  
  void (^changeType)(NSString *text) = ^(NSString *text) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[cell detailTextLabel] setText:text];
    [[self recipeMO] setValue:text forKey:@"type"];
  };
  
  [viewController setManagedObjectContext:[[self recipeMO] managedObjectContext]];
  [viewController setTypeChangedBlock:changeType];
}

- (void)prepareForSetServingsSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
  id viewController = [segue destinationViewController];
  [[viewController textField] setText:[[[self recipeMO] valueForKey:@"serves"] stringValue]];
  
  BOOL (^changedText)(NSString *text, NSError **error) = ^(NSString *text, NSError **error) {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    NSNumber *servings = [numberFormatter numberFromString:text];
    if (!servings) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionary];
      [dict setValue:@"Invalid servings" forKey:NSLocalizedDescriptionKey];
      *error = [NSError errorWithDomain:@"PragProg" code:1123 userInfo:dict];
      return NO;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[cell detailTextLabel] setText:text];
    [[self recipeMO] setValue:servings forKey:@"serves"];
    
    return YES;
  };
  
  [viewController setTextChangedBlock:changedText];
}

- (void)prepareForSetDateSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
  id viewController = [segue destinationViewController];
  [[viewController datePicker] setDate:[[self recipeMO] valueForKey:@"lastUsed"]];
  
  void (^changeDate)(NSDate *newDate) = ^(NSDate *newDate) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:0];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[self recipeMO] setValue:newDate forKey:@"lastUsed"];
    [[cell detailTextLabel] setText:[[self recipeMO] lastUsedString]];
  };
  
  [viewController setDateChangedBlock:changeDate];
}

- (void)prepareForSelectAuthorSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
  id viewController = [segue destinationViewController];
  [viewController setManagedObjectContext:[[self recipeMO] managedObjectContext]];
  
  void (^selectAuthor)(NSManagedObject *authorMO) = ^(NSManagedObject *authorMO) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:4 inSection:0];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[self recipeMO] setValue:authorMO forKey:@"author"];
    [[cell detailTextLabel] setText:[authorMO valueForKey:@"name"]];
  };
  
  [viewController setSelectAuthorBlock:selectAuthor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"editRecipeName"]) {
    [self prepareForEditRecipeNameSegue:segue sender:sender];
  } else if ([[segue identifier] isEqualToString:@"selectRecipeType"]) {
    [self prepareForSelectTypeSegue:segue sender:sender];
  } else if ([[segue identifier] isEqualToString:@"selectNumberOfServings"]) {
    [self prepareForSetServingsSegue:segue sender:sender];
  } else if ([[segue identifier] isEqualToString:@"selectLastUsed"]) {
    [self prepareForSetDateSegue:segue sender:sender];
  } else if ([[segue identifier] isEqualToString:@"selectAuthor"]) {
    [self prepareForSelectAuthorSegue:segue sender:sender];
  }
}

#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

@end
