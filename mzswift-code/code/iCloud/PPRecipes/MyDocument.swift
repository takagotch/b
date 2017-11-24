//
//  MyDocument.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/20/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import AppKit

class MyDocument: NSPersistentDocument {

  override func configurePersistentStoreCoordinatorForURL(url: NSURL,
    ofType fileType: String, modelConfiguration configuration: String?,
    storeOptions: [String : AnyObject]?) throws {

    var options = [String:AnyObject]()
    if let inStoreOptions = storeOptions {
      for (key, value) in inStoreOptions {
        options[key] = value
      }
    }

    let fileMan = NSFileManager.defaultManager()
    if let cloudURL = fileMan.URLForUbiquityContainerIdentifier(nil),
      let pathComp = url.lastPathComponent,
      let identifier = NSBundle.mainBundle().bundleIdentifier {

      let finalURL = cloudURL.URLByAppendingPathComponent(pathComp)
      options[NSPersistentStoreUbiquitousContentNameKey] = identifier
      options[NSPersistentStoreUbiquitousContentURLKey] = finalURL

    } else {
      fatalError("Missing component to initialize persistent store")
    }

    return try super.configurePersistentStoreCoordinatorForURL(url,
      ofType: fileType, modelConfiguration: configuration,
      storeOptions: options)
  }
}