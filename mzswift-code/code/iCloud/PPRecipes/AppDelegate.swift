//
//  AppDelegate.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import UIKit

let kInsertCellIdentifier = "kInsertCellIdentifier"
let kCellIdentifier = "kCellIdentifier"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var fileToOpenURL: URL?
  var dataController: PPRDataController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    dataController = PPRDataController() {
      self.contextInitialized()
    }
    guard let navController = window?.rootViewController as? UINavigationController else {
      fatalError("Root view controller is not a navigation controller")
    }
    guard let controller = navController.topViewController as? PPRMasterViewController else {
      fatalError("Top view controller is not a master view controller")
    }

    controller.managedObjectContext = dataController?.mainContext

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    dataController?.saveContext()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    dataController?.saveContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    dataController?.saveContext()
  }

  func contextInitialized() {
    if let url = self.fileToOpenURL {
      self.consumeIncomingFileURL(url)
    }
  }

  func consumeIncomingFileURL(_ url: URL) {
    guard let data = try? Data(contentsOf: url) else {
      print("No data loaded")
      return
    }
    guard let moc = dataController?.mainContext else {
      fatalError("mainContext is nil")
    }
    let op = PPRImportOperation(data: data, context: moc, handler: {
      (incomingError) in
      if let error = incomingError {
        print("Error importing data: \(error)")
        //Present an error to the user
      } else {
        //Clear visual feedback
      }
    })
    OperationQueue.main.addOperation(op)
    //Give visual feedback of the import
  }

  func application(_ application: UIApplication, open url: URL,
    sourceApplication: String?, annotation: Any) -> Bool {
    guard let controller = dataController else {
      fileToOpenURL = url
      return true
    }
    if controller.persistenceInitialized {
      consumeIncomingFileURL(url)
    } else {
      fileToOpenURL = url
    }
    return true
  }

}
