/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
//
//  PPRDataController.h
//  PPRecipes
//
//  Created by Marcus S. Zarra on 10/15/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PPRDataController : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIManagedDocument *managedDocument;

- (instancetype)initWithCompletion:(void(^)(void))block;
- (void)saveContext;

@end
