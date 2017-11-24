/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  AudioManager.m
//  Tasks
//
//  Created by Tony Hillerson on 8/18/13.
//  Copyright (c) 2013 Programming Sound. All rights reserved.
//

#import "PdInterface.h"
#import "PdDispatcher.h"
#import "PdBase.h"

#define kModulator1Tune @"mod1_tune"
#define kModulator1Depth @"mod1_depth"
#define kModulator2Tune @"mod2_tune"
#define kModulator2Depth @"mod2_depth"
#define kMidiNote1 @"midinote1"
#define kMidiNote2 @"midinote2"
#define kNoteDelay .12
#define kRootMidiNote 60.

@interface PdInterface () {
    void *patch;
    int currentOctave;
    int currentDegree;
    int currentRootNote;
    int currentSecondNote;
    NSArray *scaleDegrees;
}

@property(nonatomic, strong) PdDispatcher *pdDispatcher;

@end

@implementation PdInterface

- (id) init {
    self = [super init];
    if (self) {
        scaleDegrees = @[@0, @2, @4, @5, @7, @9, @11, @12, @14, @16];
        self.pdDispatcher = [[PdDispatcher alloc] init];
        [PdBase setDelegate:self.pdDispatcher];
        patch = [PdBase openFile:@"task_tones.pd"
                            path:[[NSBundle mainBundle] resourcePath]];
        // Initialize the FM operator settings. Could be read from config
        [PdBase sendFloat:8. toReceiver:kModulator1Tune];
        [PdBase sendFloat:5000. toReceiver:kModulator1Depth];
        [PdBase sendFloat:2.5 toReceiver:kModulator2Depth];
        [PdBase sendFloat:12000. toReceiver:kModulator2Tune];
        [self resetScaleDegree];
    }
    return self;
}

- (void) resetScaleDegree {
    currentRootNote = kRootMidiNote;
    int secondDegree = [scaleDegrees[2] integerValue];
    currentSecondNote = kRootMidiNote + secondDegree;
    currentDegree = 0;
    currentOctave = 0;
}

- (void) incrementScaleDegree {
    currentDegree = currentDegree + 1;
    if (currentDegree == 7) {
        currentDegree = 0;
        currentOctave = currentOctave + 1;
    }
    int rootDegree = [scaleDegrees[currentDegree] integerValue];
    int nextDegree = [scaleDegrees[currentDegree + 2] integerValue];
    currentRootNote = kRootMidiNote + (12 * currentOctave) + rootDegree;
    currentSecondNote = kRootMidiNote + (12 * currentOctave) + nextDegree;
}

- (void) playTaskCreatedCue {
    [PdBase sendFloat:kRootMidiNote toReceiver:kMidiNote1];
    [self resetScaleDegree];
}

- (void) playTaskCompletionCue {
    float secondNote = currentSecondNote;
    [PdBase sendFloat:currentRootNote toReceiver:kMidiNote1];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(kNoteDelay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [PdBase sendFloat:secondNote toReceiver:kMidiNote2];
    });
    [self incrementScaleDegree];
}

- (void) playTasksClearedCue {
    float root = kRootMidiNote;
    float third = kRootMidiNote + [scaleDegrees[2] integerValue];
    [PdBase sendFloat:root toReceiver:kMidiNote1];
    [PdBase sendFloat:third toReceiver:kMidiNote2];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(kNoteDelay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [PdBase sendFloat:root + 12 toReceiver:kMidiNote1];
        [PdBase sendFloat:third + 12 toReceiver:kMidiNote2];
    });
    [self resetScaleDegree];
}

@end
