/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
//
//  ZSContextWatcher.m
//
//  Copyright 2010 Zarra Studios, LLC All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "ZSContextWatcher.h"

@interface ZSContextWatcher()

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;

@property (nonatomic, retain) NSPredicate *masterPredicate;
@property (nonatomic, retain) NSString *reference;

@end

@implementation ZSContextWatcher

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
{
  ZAssert(context, @"Context is nil!");
  if (!(self = [super init])) return nil;
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(contextUpdated:)
                 name:NSManagedObjectContextDidSaveNotification
               object:context];
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addEntityToWatch:(NSEntityDescription*)description
           withPredicate:(NSPredicate*)predicate;
{
  NSPredicate *entityPredicate = nil;
  NSPredicate *final = nil;
  NSArray *array = nil;
  entityPredicate = [NSPredicate predicateWithFormat:@"entity.name == %@",
                    [description name]];
  array = [NSArray arrayWithObjects:entityPredicate, predicate, nil];
  final = [NSCompoundPredicate andPredicateWithSubpredicates:array];
  
  if (![self masterPredicate]) {
    [self setMasterPredicate:finalPredicate];
    return;
  }

  array = [NSArray arrayWithObjects:[self masterPredicate], final, nil];
  finalPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:array];
  [self setMasterPredicate:finalPredicate];
}

- (void)contextUpdated:(NSNotification*)notification
{
  NSInteger totalCount = 0;
  NSSet *temp = nil;
  temp = [[notification userInfo] objectForKey:NSInsertedObjectsKey]
  NSMutableSet *inserted = [temp mutableCopy];
  if ([self masterPredicate]) {
    [inserted filterUsingPredicate:[self masterPredicate]];
  }
  totalCount += [inserted count];
  
  temp = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
  NSMutableSet *deleted = [temp mutableCopy];
  if ([self masterPredicate]) {
    [deleted filterUsingPredicate:[self masterPredicate]];
  }
  totalCount += [deleted count];
  
  temp = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
  NSMutableSet *updated = [temp mutableCopy];
  if ([self masterPredicate]) {
    [updated filterUsingPredicate:[self masterPredicate]];
  }
  totalCount += [updated count];
  
  if (totalCount == 0) {
    return;
  }
  
  NSMutableDictionary *results = [NSMutableDictionary dictionary];
  if (inserted) {
    [results setObject:inserted forKey:NSInsertedObjectsKey];
  }
  if (deleted) {
    [results setObject:deleted forKey:NSDeletedObjectsKey];
  }
  if (updated) {
    [results setObject:updated forKey:NSUpdatedObjectsKey];
  }
  
  if ([[self delegate] respondsToSelector:[self action]]) {
    [[self delegate] performSelectorOnMainThread:[self action] 
                                      withObject:self 
                                   waitUntilDone:YES];
  }
}

@end
