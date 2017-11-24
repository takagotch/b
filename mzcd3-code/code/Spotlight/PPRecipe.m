/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRecipe.h"

@implementation PPRecipe

@dynamic desc;
@dynamic name;
@dynamic type;
@dynamic author;
@dynamic lastUsed;

- (NSDictionary*)metadata;
{
  NSMutableDictionary *metadataDict = [NSMutableDictionary dictionary];
  metadataDict[kPPItemTitle] = [self name];
  metadataDict[kPPItemTextContent] = [self desc];
  metadataDict[kPPItemAuthors] = [[self author] valueForKey:@"name"];
  metadataDict[kPPImagePath] = [self valueForKey:@"imagePath"];
  metadataDict[kPPItemLastUsedDate] = [self lastUsed];
  metadataDict[kPPServes] = [self valueForKey:@"serves"];
  NSString *temp = [NSString stringWithFormat:@"Recipe: %@", [self name]];
  metadataDict[kPPObjectID] = temp;
  temp = [[[self objectID] URIRepresentation] absoluteString];
  metadataDict[(id)kMDItemTitle] = temp;
  return metadataDict;
}

- (NSString*)metadataFilename;
{
  return [[self name] stringByAppendingPathExtension:@"grokkingrecipe"];
}

@end
