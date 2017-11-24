/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  TaskListViewController.m
//  Tasks
//
//  Created by Tony Hillerson on 8/4/13.
//  Copyright (c) 2013 Programming Sound. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskCell.h"
#import "AppDelegate.h"
#import "PdInterface.h"

static NSString *TaskCellReuseID = @"TaskCell";

@interface TaskListViewController () <NSFetchedResultsControllerDelegate> {
    BOOL removingCompleted;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property(nonatomic, strong) NSFetchedResultsController *tasksFetchedResultsController;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) UIAlertView *clearCompleteAlertView;
@property(nonatomic, strong) PdInterface *pdInterface;

@end

@implementation TaskListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSFetchRequest *tasksFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tasks"];
        tasksFetchRequest.sortDescriptors = @[
                                              [[NSSortDescriptor alloc] initWithKey:@"complete" ascending:YES],
                                              [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO] ];
        NSManagedObjectContext *moc = [AppDelegate sharedInstance].managedObjectContext;
        self.tasksFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:tasksFetchRequest
                                                                                 managedObjectContext:moc
                                                                                   sectionNameKeyPath:@"complete"
                                                                                            cacheName:nil];
        self.tasksFetchedResultsController.delegate = self;
        [self.tasksFetchedResultsController performFetch:NULL];
        
        self.pdInterface = [AppDelegate sharedInstance].pdInterface;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[TaskCell class] forCellWithReuseIdentifier:TaskCellReuseID];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(addNewTask) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = nil;
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void) addNewTask {
    [self.refreshControl endRefreshing];
    NSManagedObjectContext *moc = [AppDelegate sharedInstance].managedObjectContext;
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Tasks"
                                            inManagedObjectContext:moc];
    NSManagedObject *task = [[NSManagedObject alloc] initWithEntity:desc
                                     insertIntoManagedObjectContext:moc];
    [task setValue:@"New Task" forKey:@"title"];
    [task setValue:[NSDate date] forKey:@"createdAt"];
    [self.collectionView reloadData];
}

- (void) removeComplete {
    removingCompleted = YES;
    NSManagedObjectContext *moc = [AppDelegate sharedInstance].managedObjectContext;
    NSArray *sections = [self.tasksFetchedResultsController sections];
    int sectionToClear = 0;
    if ([sections count] == 2) {
        sectionToClear = 1;
    }
    [[[sections objectAtIndex:sectionToClear] objects] enumerateObjectsUsingBlock:^(NSManagedObject *task, NSUInteger idx, BOOL *stop) {
        [moc deleteObject:task];
    }];
    [moc save:NULL];
    [self.collectionView performBatchUpdates:^{
        NSIndexSet *deletedSections = [NSIndexSet indexSetWithIndex:sectionToClear];
        [self.collectionView deleteSections:deletedSections];
    } completion:^(BOOL finished) {
        removingCompleted = NO;
    }];
}

#pragma mark - Collection View Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sectionCount = [self.tasksFetchedResultsController.sections count];
    if (sectionCount == 0) {
        self.instructionLabel.hidden = NO;
    } else {
        self.instructionLabel.hidden = YES;
    }
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[[self.tasksFetchedResultsController sections] objectAtIndex:section] objects] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell *cell = (TaskCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:TaskCellReuseID forIndexPath:indexPath];
    NSManagedObject *task = [self.tasksFetchedResultsController objectAtIndexPath:indexPath];
    [cell setTask:task];
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *task = [self.tasksFetchedResultsController objectAtIndexPath:indexPath];
    BOOL completed = [[task valueForKey:@"complete"] boolValue];
    if (completed) {
        NSString *desc = @"Remove All Complete Tasks?";
        NSString *remove =  @"Remove";
        NSString *cancel =  @"Cancel";

        self.clearCompleteAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:desc
                                                                delegate:self
                                                       cancelButtonTitle:cancel
                                                       otherButtonTitles:remove, nil];
        [self.clearCompleteAlertView show];
    }
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [self removeComplete];
    }
    self.clearCompleteAlertView = nil;
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!removingCompleted) {
        double delayInSeconds = .3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.collectionView reloadData];
        });
    }
}

@end
