/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import <Cocoa/Cocoa.h>

#define kPPImagePath @"kPPImagePath"
#define kPPObjectID @"kPPObjectID"
#define kPPServes @"kPPServes"
#define kPPItemTitle (id)kMDItemTitle
#define kPPItemTextContent (id)kMDItemTextContent
#define kPPItemAuthors (id)kMDItemAuthors
#define kPPItemLastUsedDate (id)kMDItemLastUsedDate
#define kPPItemDisplayName (id)kMDItemDisplayName

@interface PPRecipe : NSManagedObject

@property (assign) NSString *desc;
@property (assign) NSString *name;
@property (assign) NSString *type;
@property (assign) NSManagedObject *author;
@property (assign) NSDate *lastUsed;

- (NSDictionary*)metadata;
- (NSString*)metadataFilename;

@end
