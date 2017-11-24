/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Foundation/Foundation.h>

OSStatus GenerateThumbnailForURL(void *thisInterface,
                                 QLThumbnailRequestRef thumbnail,
                                 CFURLRef url,
                                 CFStringRef contentTypeUTI,
                                 CFDictionaryRef options,
                                 CGSize maxSize)
{
  @autoreleasepool {
    NSDictionary *meta;
    meta = [NSDictionary dictionaryWithContentsOfURL:(__bridge NSURL*)url];
    NSString *pathToImage = [meta valueForKey:@"kPPImagePath"];
    if (!pathToImage) {
      //No image available
      return noErr;
    }
    NSData *imageData = [NSData dataWithContentsOfFile:pathToImage];
    if (!imageData) {
      //Unable to load the data for some reason.
      return noErr;
    }
    QLThumbnailRequestSetImageWithData(thumbnail,
                                       (__bridge CFDataRef)imageData, NULL);
  }
  return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
  // implement only if supported
}
