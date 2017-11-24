//
//  PPRRecipeMO.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

let kPPImagePath = "kPPImagePath"
let kPPObjectID = "kPPObjectID"
let kPPServes = "kPPServes"
let kPPItemTitle = kMDItemTitle as String
let kPPItemTextContent = kMDItemTextContent as String
let kPPItemAuthors = kMDItemAuthors as String
let kPPItemLastUsedDate = kMDItemLastUsedDate as String
let kPPItemDisplayName = kMDItemDisplayName as String

class PPRRecipeMO: NSManagedObject {
  @NSManaged var desc: String?
  @NSManaged var imagePath: String?
  @NSManaged var lastUsed: Date?
  @NSManaged var name: String?
  @NSManaged var serves: NSNumber?
  @NSManaged var type: String

  @NSManaged var author: NSManagedObject?
  @NSManaged var ingredients: [NSManagedObject]?

  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  func lastUsedString() -> String {
    if let date = self.value(forKey: "lastUsed") as? Date {
      return dateFormatter.string(from: date)
    } else {
      return "Never Used"
    }
  }

  func metadata() -> NSDictionary {
    let metadata = NSMutableDictionary()
    guard let name = name else { fatalError("Malformed Recipe, no name") }
    metadata[kPPItemTitle] = name
    if let desc = desc { metadata[kPPItemTextContent] = desc }
    if let author = author, let name = author.value(forKey: "name") {
        metadata[kPPItemAuthors] = name
    }
    metadata[kPPImagePath] = imagePath
    metadata[kPPItemLastUsedDate] = lastUsed
    metadata[kPPServes] = serves
    metadata[kPPObjectID] = objectID.uriRepresentation().absoluteString
    return metadata
  }

  func metadataFilename() -> String {
    guard let name = name else { fatalError("Malformed Recipe, no name") }
    return "\(name).grokkingrecipe"
  }

}
