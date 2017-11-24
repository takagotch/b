/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
//
//  PPRMasterViewController.h
//  PPRecipes
//
//  Created by Marcus Zarra on 4/3/12.
//  Copyright (c) 2015 The Pragmatic Programmer. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PPRDetailViewController;
@class PPRDataController;

@interface PPRMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PPRDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) PPRDataController *dataController;

@end
