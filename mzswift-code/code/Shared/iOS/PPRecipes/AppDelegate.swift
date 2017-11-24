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

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    dataController = PPRDataController() {
      (inError) in
      if let error = inError {
        self.displayError(error: error)
      } else {
        self.contextInitialized()
      }
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

  func displayError(error: Error) {
    var message = "The recipes database is either corrupt or was created by a"
    message += " newer version of Grokking Recipes. Please contact support to"
    message += " assist with this error. \n\(error.localizedDescription)"
    let alert = UIAlertController(title: "Error", message: message,
      preferredStyle: .alert)
    let close = UIAlertAction(title: "Close", style: .cancel, handler: {
      (action) in
      //Probably terminate the application
    })
    alert.addAction(close)
    if let controller = window?.rootViewController {
      controller.present(alert, animated: true, completion: nil)
    }
  }

  func contextInitialized() {
    if let url = self.fileToOpenURL {
      do {
        try self.consumeIncomingFileURL(url)
      } catch {
        print("Error consuming URL: \(error)")
      }
    }
  }

  func consumeIncomingFileURL(_ url: URL) throws {
    let data = try Data(contentsOf: url)
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

  func application(_ app: UIApplication, open url: URL,
    options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    guard let controller = dataController else {
      fileToOpenURL = url
      return true
    }
    if controller.persistenceInitialized {
      do {
        try self.consumeIncomingFileURL(url)
      } catch {
        print("Error consuming URL: \(error)")
      }
    } else {
      fileToOpenURL = url
    }
    return true
  }

}
