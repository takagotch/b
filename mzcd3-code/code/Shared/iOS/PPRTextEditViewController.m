/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRTextEditViewController.h"

@interface PPRTextEditViewController () <UITextFieldDelegate>

@end

@implementation PPRTextEditViewController

@synthesize textField;
@synthesize textChangedBlock;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
  
  if (![[self navigationItem] rightBarButtonItem]) {
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
  } else {
    return YES;
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [[self textField] becomeFirstResponder];
}

- (IBAction)done:(id)sender;
{
  if ([self textFieldShouldReturn:[self textField]]) {
    [[self navigationController] popViewControllerAnimated:YES];
  }
}

- (IBAction)cancel:(id)sender;
{
  [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)$textField
{
  NSString *text = [$textField text];
  NSError *error = nil;
  BOOL success = [self textChangedBlock](text, &error);
  if (success) return success;
  
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
  [alertView show];
  
  return NO;
}

@end
