/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>

#import <Foundation/Foundation.h>

NSString *bundleID = @"com.pragprog.quicklook.grokkingrecipe";

OSStatus GeneratePreviewForURL(void *thisInterface, 
                               QLPreviewRequestRef preview, 
                               CFURLRef url, 
                               CFStringRef contentTypeUTI, 
                               CFDictionaryRef options)
{
  @autoreleasepool {
    NSDictionary *meta;
    meta = [NSDictionary dictionaryWithContentsOfURL:(__bridge NSURL*)url];
    if (!metadata) return noErr;
    NSLog(@"metadata: %@", metadata);
    
    NSString *imagePath = [metadata valueForKey:@"kPPImagePath"];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
    if (!imageData) return noErr;
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
    [imageDict setValue:imageData 
                 forKey:(id)kQLPreviewPropertyAttachmentDataKey];
    
    if (QLPreviewRequestIsCancelled(preview)) return noErr;
    
    NSMutableDictionary *attachments = [NSMutableDictionary dictionary];
    [attachments setValue:imageDict forKey:@"preview-image"];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setValue:attachments 
                  forKey:(id)kQLPreviewPropertyAttachmentsKey];
    [properties setValue:@"text/html" 
                  forKey:(id)kQLPreviewPropertyMIMETypeKey];
    [properties setValue:@"UTF-8" 
                  forKey:(id)kQLPreviewPropertyTextEncodingNameKey];
    [properties setValue:@"Recipe" 
                  forKey:(id)kQLPreviewPropertyDisplayNameKey];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleID];
    NSString *tPath = [bundle pathForResource:@"preview" ofType:@"html"];
    NSURL *templateURL = [NSURL fileURLWithPath:tPath];
        
    NSError *error = nil;
    NSXMLDocument *temp;
    temp = [[NSXMLDocument alloc] initWithContentsOfURL:(NSURL*)templateURL
                                                options:NSXMLDocumentTidyHTML 
                                                  error:&error];
    if (!template) {
      NSLog(@"Failed to build template: %@", error);
      return noErr;
    }
    //Updating the Title
    error = nil;
    NSXMLElement *element = nil;
    element = [[temp nodesForXPath:@"/html/body/div/*[@id='title']" 
                             error:&error] lastObject];
    if (!element) {
      NSLog(@"Failed to find element: %@", error);
      return noErr;
    }
    [element setStringValue:[metadata valueForKey:(id)kMDItemDisplayName]];
    
    //Updating the description
    error = nil;
    element = [[template nodesForXPath:@"/html/body/div/*[@id='description']" 
                                 error:&error] lastObject];
    if (!element) {
      NSLog(@"Failed to find element: %@", error);
      return noErr;
    }
    [element setStringValue:[metadata valueForKey:(id)kMDItemTextContent]];
    
    //Updating the serves value
    error = nil;
    element = [[template nodesForXPath:@"/html/body/div/*[@id='serves']" 
                                 error:&error] lastObject];
    if (!element) {
      NSLog(@"Failed to find element: %@", error);
      return noErr;
    }
    NSNumber *serves = [metadata valueForKey:@"kPPServes"];
    [element setStringValue:[NSString stringWithFormat:@"Serves: %li", 
                             (long)[serves integerValue]]];
    
    //Updating the last served value
    error = nil;
    element = [[template nodesForXPath:@"/html/body/div/*[@id='last_served']" 
                                 error:&error] lastObject];
    if (!element) {
      NSLog(@"Failed to find element: %@", error);
      return noErr;
    }
    NSDate *lastServedDate = [metadata valueForKey:(id)kMDItemLastUsedDate];
    if (lastServedDate) {
      NSDateFormatter *dateFormatter;
      dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
      [element setStringValue:[NSString stringWithFormat:@"Last Served: %@", 
                              [dateFormatter stringFromDate:lastServedDate]]];
    } else {
      [element setStringValue:@"Last Served: Never"];
    }
                   
    QLPreviewRequestSetDataRepresentation(preview, 
      (__bridge CFDataRef)[template XMLData],
      kUTTypeHTML, 
      (__bridge CFDictionaryRef)properties);
  }
  return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
