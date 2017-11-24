/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
//
//  PdMidiDispatcher.h
//  libpd
//
//  Copyright (c) 2013 Dan Wilcox (danomatika@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import <Foundation/Foundation.h>
#import "PdBase.h"

// Implementation of the PdMidiReceiverDelegate protocol from PdBase.h.  Client code
// registers one instance of this class with PdBase, and then listeners for individual
// channels will be registered with the dispatcher object.
//
// Raw MIDI bytes are only printed by default; subclass and override the receiveMidiByte
// method if you want to handle raw MIDI aka data sent to [midiout].
@interface PdMidiDispatcher : NSObject<PdMidiReceiverDelegate> {
  NSMutableDictionary *listenerMap;
}

// Adds a listener for the given MIDI channel in Pd.
- (int)addListener:(NSObject<PdMidiListener> *)listener forChannel:(int)channel;

// Removes a listener for a channel.
- (int)removeListener:(NSObject<PdMidiListener> *)listener forChannel:(int)channel;

// Removes all listeners.
- (void)removeAllListeners;
@end

// Subclass of PdMidiDisptcher that logs all callbacks, mostly for development and debugging.
@interface LoggingMidiDispatcher : PdMidiDispatcher {}
@end
