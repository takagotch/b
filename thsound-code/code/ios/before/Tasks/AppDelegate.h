/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  AppDelegate.h
//  Tasks
//
//  Created by Tony Hillerson on 8/4/13.
//  Copyright (c) 2013 Programming Sound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#import "PdInterface.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic,strong) PdAudioController *pdAudioController;
@property(nonatomic,strong) PdInterface *pdInterface;

+ (AppDelegate *) sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
