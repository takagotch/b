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
    var dataController = PPRDataController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let navController = window?.rootViewController as? UINavigationController else {
            fatalError("Root view controller is not a navigation controller")
        }
        guard let controller = navController.topViewController as? PPRMasterViewController else {
            fatalError("Top view controller is not a master view controller")
        }

        controller.managedObjectContext = dataController.mainContext

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dataController.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dataController.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dataController.saveContext()
    }

}

