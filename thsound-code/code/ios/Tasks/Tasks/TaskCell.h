/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  TaskCell.h
//  Tasks
//
//  Created by Tony Hillerson on 8/4/13.
//  Copyright (c) 2013 Programming Sound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UICollectionViewCell

@property(nonatomic, strong) NSManagedObject *task;

@end
