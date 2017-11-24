/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  PdAudioUnit.h
//  libpd
//
//  Created on 29/09/11.
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import <Foundation/Foundation.h>
#import "AudioUnit/AudioUnit.h"

/* PdAudioUnit: object that operates pd's audio input and
 * output through an Audio Unit. The parameters can be changed
 * after it has been instatiated with its configure method,
 * which will cause the underlying audio unit to be reconstructed.
 *
 * For debugging, AU_DEBUG_VERBOSE can be defined to print extra information.
 */
@interface PdAudioUnit : NSObject

// A reference to the audio unit, which can be used to query or set other properties
@property (nonatomic, readonly) AudioUnit audioUnit;

// Check or set the active status of the audio unit
@property (nonatomic, getter = isActive) BOOL active;

// The configure method sets all parameters of the audio unit that may require it to be
// re-created at the same time.  This is an expensive process and will stop the audio unit
// before any reconstruction, causing a momentary pause in audio and UI if
// run from the main thread.  Returns zero on success.
- (int)configureWithSampleRate:(Float64)sampleRate numberChannels:(int)numChannels inputEnabled:(BOOL)inputEnabled;

// Print info on the audio unit settings to the console
- (void)print;

@end
