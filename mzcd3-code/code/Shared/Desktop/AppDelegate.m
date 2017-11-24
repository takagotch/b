/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.dataController = [[PPRDataController alloc] init];
}

- (IBAction)addImage:(id)sender;
{
  NSManagedObject *recipe = nil;
  recipe = [[self.recipeArrayController selectedObjects] lastObject];
  if (!recipe) return;
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];

  [openPanel beginSheetModalForWindow:self.window
                    completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelCancelButton) return;
    NSURL *fileURL = [[openPanel URLs] lastObject];
    NSError *error = nil;
    //Build the path we want the file to be at
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directories = nil;
    directories = [fileManager URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask];
    NSURL *destURL = [directories lastObject];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    destURL = [destURL URLByAppendingPathComponent:guid];
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:fileURL
                                                           toURL:destURL
                                                           error:&error];
    NSAssert2(success, @"Error copying file: %@\n%@",
              [error localizedDescription], [error userInfo]);
    [recipe setValue:[destURL path] forKey:@"imagePath"];
  }];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
  return [self.dataController.managedObjectContext undoManager];
}

- (IBAction) saveAction:(id)sender
{
  [self.dataController saveContext];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender
{
  [self.dataController saveContext];
  return NSTerminateNow;
}

@end
