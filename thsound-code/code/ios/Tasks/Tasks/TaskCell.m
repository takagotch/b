/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  TaskCell.m
//  Tasks
//
//  Created by Tony Hillerson on 8/4/13.
//  Copyright (c) 2013 Programming Sound. All rights reserved.
//

#import "TaskCell.h"
#import "AppDelegate.h"
#import "PdInterface.h"

static CGFloat kAnimationDuration = .3;
static CGFloat kCompletePositionFactor = 1.0/3.0;

@interface TaskCell () <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    CGPoint panBegin;
    CGPoint panAdjusted;
    BOOL completed;
    BOOL toggleGestureCompleted;
}

@property(nonatomic, strong) UITextField *titleLabel;
@property(nonatomic, strong) UIPanGestureRecognizer *panRightRecognizer;
@property(nonatomic, strong) PdInterface *pdInterface;

@end

@implementation TaskCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel = [UITextField new];
        self.titleLabel.delegate = self;
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.panRightRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRight:)];
        self.panRightRecognizer.delegate = self;
        [self addGestureRecognizer:self.panRightRecognizer];
        
        [self addSubview:self.titleLabel];
        
        self.pdInterface = [AppDelegate sharedInstance].pdInterface;
    }
    return self;
}

- (void) setTask:(NSManagedObject *)aTask {
    _task = aTask;
    self.titleLabel.text = [aTask valueForKey:@"title"];
    completed = [[aTask valueForKey:@"complete"] boolValue];
    [self configureStyles];
}

- (void) configureStyles {
    if ([self isSwipeFarEnoughForTaskCompleteToggle]) {
        self.titleLabel.backgroundColor = [UIColor greenColor];
    } else {
        if (completed) {
            self.titleLabel.backgroundColor = [UIColor lightGrayColor];
            self.titleLabel.enabled = NO;
        } else {
            self.titleLabel.backgroundColor = [UIColor whiteColor];
            self.titleLabel.enabled = YES;
        }
    }
}

- (BOOL) isSwipeFarEnoughForTaskCompleteToggle {
    CGFloat labelX = self.titleLabel.frame.origin.x;
    CGFloat width = self.frame.size.width;
    return labelX >= width * kCompletePositionFactor;
}

- (void) positionLabel {
    if (panAdjusted.x >= 0) {
        if (CGPointEqualToPoint(CGPointMake(0, 0), panAdjusted)) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.titleLabel.frame = self.bounds;
            }];
        } else {
            CGRect frame = self.titleLabel.frame;
            self.titleLabel.frame = CGRectMake(panAdjusted.x, frame.origin.y, frame.size.width, frame.size.height);
            [self configureStyles];
        }
    }
}

- (void) saveChanges {
    NSString *newTitle = self.titleLabel.text;
    BOOL currentComplete = [[self.task valueForKey:@"complete"] boolValue];
    [self.task setValue:newTitle forKey:@"title"];
    if (toggleGestureCompleted) {
        completed = !currentComplete;
        [self.task setValue:@(completed) forKey:@"complete"];
        toggleGestureCompleted = NO;
    }
    [self performSelectorInBackground:@selector(saveChangesInBackground) withObject:nil];
}

- (void) saveChangesInBackground {
    [[self.task managedObjectContext] save:NULL];
}

- (void) playToneForGesture {
    if (completed) {
        [self.pdInterface playTaskCreatedCue];
    } else {
        [self.pdInterface playTaskCompletionCue];
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveChanges];
}

#pragma mark - Gestures

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

- (void) panRight:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        panBegin = [recognizer translationInView:self];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint gesturePoint = [recognizer translationInView:self];
        CGFloat newX = gesturePoint.x - panBegin.x;
        panAdjusted.x = newX;
    } else {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            toggleGestureCompleted = [self isSwipeFarEnoughForTaskCompleteToggle];
            if (toggleGestureCompleted) {
                [self playToneForGesture];
            }
            
            [self saveChanges];
            [self configureStyles];
        }
        panAdjusted = panBegin = CGPointMake(0, 0);
    }
    [self positionLabel];
}

#pragma mark - Table View Cell

- (void) layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = @"";
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.task = nil;
    completed = NO;
    toggleGestureCompleted = NO;
}

@end
