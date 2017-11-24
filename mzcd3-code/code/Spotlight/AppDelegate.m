/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "AppDelegate.h"

#import "PPRecipe.h"

@interface AppDelegate()

- (void)selectRecipe:(NSManagedObject*)recipe;
- (void)addImage:(NSURL*)imagePath toRecipe:(PPRecipe*)recipe;

- (NSString*)applicationSupportFolder;
- (NSString*)metadataFolder:(NSError**)error;

- (BOOL)save:(NSError**)error;

- (BOOL)updateMetadataForObjects:(NSSet*)updatedObjects
               andDeletedObjects:(NSSet*)deletedObjects
                           error:(NSError**)error;

@end

@implementation AppDelegate

#pragma mark Application Delegate methods

- (instancetype)init
{
  if (!(self = [super init])) {
    NSLog(@"Failed to initiliaze app delegate");
    abort();
  }

  self.dataController = [[PPRDataController alloc] init];

  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
  [[self imageView] addObserver:self
                     forKeyPath:@"imagePath"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
  NSError *error = nil;
  NSString *path = [self metadataFolder:&error];
  if (!path) {
    NSLog(@"%s Error resolving cache path: %@", __PRETTY_FUNCTION__, error);
    return;
  }
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return;

  NSManagedObjectContext *moc = [self managedObjectContext];
  NSFetchRequest *request = nil;
  request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];

  NSSet *recipes = [NSSet setWithArray:[moc executeFetchRequest:request
                                                          error:&error]];
  if (error) {
    NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    return;
  }
  [self updateMetadataForObjects:recipes andDeletedObjects:nil error:&error];
  if (error) {
    NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    return;
  }
}

- (BOOL)application:(NSApplication*)theApplication
           openFile:(NSString*)filename
{
  NSDictionary *meta = [NSDictionary dictionaryWithContentsOfFile:filename];
  NSString *objectIDString = [meta valueForKey:(id)kPPObjectID];
  NSURL *objectURI = [NSURL URLWithString:objectIDString];
  NSPersistentStoreCoordinator *coordinator;
  coordinator = [[self managedObjectContext] persistentStoreCoordinator];

  NSManagedObjectID *oID;
  oID = [coordinator managedObjectIDForURIRepresentation:objectURI];

  NSManagedObject *recipe = [[self managedObjectContext] objectWithID:oID];
  if (!recipe) return NO;

  dispatch_async(dispatch_get_main_queue(), ^{
    NSArray *array = [NSArray arrayWithObject:recipe];
    [[self recipeArrayController] setSelectedObjects:array];
  });

  return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender
{
  NSError *error = nil;

  if (![self.dataController.managedObjectContext commitEditing]) {
    //Failed to commit editing.
    return NSTerminateCancel;
  }
  if (![self.dataController.managedObjectContext hasChanges]) return NSTerminateNow;
  if (![self save:&error]) {
    NSLog(@"Failed to save: %@\n%@", [error localizedDescription], [error userInfo]);
    NSAlert *al = [[NSAlert alloc] init];
    [al setInformativeText:@"Could not save changes while quitting. Quit anyway?"];
    [al addButtonWithTitle:@"Quit anyway"];
    [al addButtonWithTitle:@"Cancel"];
    NSModalResponse response = [al runModal];
    if (response == NSAlertSecondButtonReturn) return NSTerminateCancel;
  }
  return NSTerminateNow;
}

#pragma mark Interface Builder Actions
#pragma mark -

- (IBAction)addImage:(id)sender;
{
  PPRecipe *recipe = [[[self recipeArrayController] selectedObjects] lastObject];
  if (!recipe) return;

  NSOpenPanel *openPanel = [NSOpenPanel openPanel];

  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];

  [openPanel beginSheetModalForWindow:[self window]
                    completionHandler:^(NSInteger result)
  {
    if (result == NSModalResponseCancel) return;
    NSURL *path = [[openPanel URLs] lastObject];
    [self addImage:path toRecipe:recipe];
  }];
}

- (IBAction)saveAction:(id)sender
{
  NSError *error = nil;
  if (![self save:&error]) {
    [[NSApplication sharedApplication] presentError:error];
  }
}

#pragma mark Helper methods
#pragma mark -

- (void)addImage:(NSURL*)imagePath toRecipe:(PPRecipe*)recipe
{
  //Build the path we want the file to be at
  NSString *destPath = [self applicationSupportFolder];
  NSURL *destURL = [NSURL fileURLWithPath:destPath];
  NSString *filename = [[NSProcessInfo processInfo] globallyUniqueString];
  destURL = [destURL URLByAppendingPathComponent:filename];
  NSError *error = nil;
  if (![[NSFileManager defaultManager] copyItemAtURL:imagePath
                                               toURL:destURL
                                               error:&error]) {
    NSLog(@"Failed to copy image: %@\n%@", [error localizedDescription],
          [error userInfo]);
    abort();

  }
  [recipe setValue:destPath forKey:@"imagePath"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
  if (object != [self imageView]) return;
  PPRecipe *recipe = [[[self recipeArrayController] selectedObjects] lastObject];
  if (!recipe) return;
  NSString *path = [[self imageView] imagePath];
  if ([path isEqualToString:[recipe valueForKey:@"imagePath"]]) return;
  NSURL *imageURL = [NSURL URLWithString:path];
  [self addImage:imageURL toRecipe:recipe];
}

- (void)selectRecipe:(NSManagedObject*)recipe;
{
  [[self recipeArrayController] setSelectedObjects:[NSArray arrayWithObject:recipe]];
}

- (NSString*)metadataFolder:(NSError**)error
{
  NSString *path = nil;
  path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
            NSUserDomainMask, YES) lastObject];
  if (!path) {
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    NSString *desc = NSLocalizedString(@"Failed to locate caches directory",
      @"caches directory error description")
    [errorDict setValue:desc forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"pragprog" 
                                 code:1000 
                             userInfo:errorDict];
    return nil;
  }
  path = [path stringByAppendingPathComponent:@"Metadata"];
  path = [path stringByAppendingPathComponent:@"GrokkingRecipes"];
  return path;
}

- (NSString*)applicationSupportFolder
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"GrokkingRecipes"];
}

- (BOOL)updateMetadataForObjects:(NSSet*)updatedObjects
               andDeletedObjects:(NSSet*)deletedObjects
                           error:(NSError**)error
{
  if ((!updatedObjects || ![updatedObjects count]) &&
      (!deletedObjects || ![deletedObjects count])) return YES;

  NSString *path = [self metadataFolder:error];
  if (!path) return NO;

  BOOL directory = NO;

  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:path isDirectory:&directory]) {
    if (![fileManager createDirectoryAtPath:path
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:error]) {
      return NO;
    }
    directory = YES;
  }
  if (!directory) {
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    NSString *msg = NSLocalizedString(@"File in place of metadata directory",
      @"metadata directory is a file error description");
    [errorDict setValue:msg forKey:NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain:@"pragprog" 
                                 code:1001 
                             userInfo:errorDict];
    return NO;
  }
  NSString *filePath = nil;
  if (deletedObjects && [deletedObjects count]) {
    for (NSString *filename in deletedObjects) {
      filePath = [path stringByAppendingPathComponent:filename];
      if (![fileManager fileExistsAtPath:filePath]) continue;
      if (![fileManager removeItemAtPath:filePath error:error]) return NO;
    }
  }

  if (!updatedObjects || ![updatedObjects count]) return YES;

  NSNumber *_YES = [NSNumber numberWithBool:YES];
  NSDictionary *attributesDictionary = [NSDictionary
                                        dictionaryWithObject:_YES
                                        forKey:NSFileExtensionHidden];
  for (id object in updatedObjects) {
    if (![object isKindOfClass:[PPRecipe class]]) continue;
    PPRecipe *recipe = object;
    NSDictionary *metadata = [recipe metadata];
    filePath = [recipe metadataFilename];
    filePath = [path stringByAppendingPathComponent:filePath];
    [metadata writeToFile:filePath atomically:YES];
    NSError *error = nil;
    if (![fileManager setAttributes:attributesDictionary
                       ofItemAtPath:filePath
                              error:&error]) {
      NSLog(@"Failed to set attributes: %@\n%@",
            [error localizedDescription], [error userInfo]);
      abort();
    }
  }

  return YES;
}

- (NSManagedObjectContext*)managedObjectContext
{
  return self.dataController.managedObjectContext;
}

- (BOOL)save:(NSError**)error;
{
  NSManagedObjectContext *moc = [self managedObjectContext];
  if (!moc) return YES;

  if (![moc hasChanges]) return YES;

  //Grab a reference to all of the objects we will need to work with
  NSSet *deleted = [moc deletedObjects];
  NSMutableSet *deletedPaths = [NSMutableSet set];
  for (NSManagedObject *object in deleted) {
    if (![object isKindOfClass:[PPRecipe class]]) continue;
    [deletedPaths addObject:[object valueForKey:@"metadataFilename"]];
  }

  NSMutableSet *updated = [NSMutableSet setWithSet:[moc insertedObjects]];
  [updated unionSet:[moc updatedObjects]];

  //Save the context
  if (![moc save:error]) {
    return NO;
  }
  return [self updateMetadataForObjects:updated
                      andDeletedObjects:deletedPaths
                                  error:error];
}

#pragma mark Window Delegate methods
#pragma mark -

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
  return [[self managedObjectContext] undoManager];
}

@end
