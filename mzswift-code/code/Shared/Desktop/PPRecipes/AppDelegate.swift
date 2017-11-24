//
//  AppDelegate.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/26/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var imageView: NSImageView? = nil
  @IBOutlet var recipeArrayController: NSArrayController? = nil
  @IBOutlet var window: NSWindow? = nil
  
  var managedObjectContext: NSManagedObjectContext {
    guard let moc = dataController.mainContext else {
      fatalError("No context")
    }
    return moc
  }

  let dataController = PPRDataController() { (error) in
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    dataController.saveContext()
  }

  @IBAction func saveAction(_ sender: AnyObject) {
    dataController.saveContext()
  }

  @IBAction func addImage(_ sender: AnyObject) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false

    guard let window = window else {
      fatalError("mainWindow is nil")
    }
    guard let recipe = recipeArrayController?.selectedObjects.last else {
      fatalError("No recipe selected")
    }

    openPanel.beginSheetModal(for: window) { (result) in
      if result == NSFileHandlingPanelCancelButton { return }
      guard let fileURL = openPanel.urls.last else {
        fatalError("Failed to retrieve openPanel.URLs")
      }

      let fileManager = FileManager.default
      let support = fileManager.urls(for: .applicationSupportDirectory,
        in: .userDomainMask)
      let guid = ProcessInfo.processInfo.globallyUniqueString
      guard let destURL = support.last?.appendingPathComponent(guid) else {
        fatalError("Failed to construct destination url")
      }

      do {
        try fileManager.copyItem(at: fileURL, to: destURL)
      } catch {
        fatalError("Failed to copy item: \(error)")
      }

      (recipe as AnyObject).setValue(destURL.path, forKey: "imagePath")
    }
  }
  
}

