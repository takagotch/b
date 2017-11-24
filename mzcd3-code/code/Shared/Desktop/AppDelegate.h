/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import <Cocoa/Cocoa.h>
#import "PPRDataController.h"

@interface AppDelegate : NSObject

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSArrayController *recipeArrayController;
@property (strong) PPRDataController *dataController;

- (IBAction)saveAction:sender;
- (IBAction)addImage:(id)sender;

@end