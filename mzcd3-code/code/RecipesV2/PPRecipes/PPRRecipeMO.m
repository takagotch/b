/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRRecipeMO.h"
@implementation PPRRecipeMO
@dynamic desc;
@dynamic imagePath;
@dynamic lastUsed;
@dynamic name;
@dynamic serves;
@dynamic type;

static NSDateFormatter *dateFormatter = nil;

- (NSString*)lastUsedString;
{
  NSDate *date = [self valueForKey:@"lastUsed"];
  if (!date) return @"Never Used";
  if (!dateFormatter) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  }
  
  return [dateFormatter stringFromDate:date];
}

@end
