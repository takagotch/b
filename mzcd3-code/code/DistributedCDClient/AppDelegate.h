/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPDistributedProtocol.h"

@interface AppDelegate : NSObject 
{
  IBOutlet NSWindow *window;
  NSTimer *pingTimer;
  NSTimer *fetchTimer;
  NSTimer *insertTimer;
  NSTimer *deleteTimer;
  NSTimer *childInsertTimer;
  NSTimer *childDeleteTimer;
  
  NSArray *filteredObjects;
  
  id server;
}

@property (retain, nonatomic) NSArray *filteredObjects;

@end
