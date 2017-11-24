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

  let dataController = PPRDataController() { (error) in
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    dataController.saveContext()
  }

  var appSupportURL: URL {
    let fileManager = FileManager.default
    let infoDict = Bundle.main.infoDictionary
    guard let s = fileManager.urls(for: .applicationSupportDirectory,
      in: .userDomainMask).last,
      let appName = infoDict?[kCFBundleNameKey as String] as? String else {
      fatalError("Failed to resolve app support directory")
    }
    return s.appendingPathComponent(appName)
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
      let guid = ProcessInfo.processInfo.globallyUniqueString
      let destURL = self.appSupportURL.appendingPathComponent(guid)

      do {
        try fileManager.copyItem(at: fileURL, to: destURL)
      } catch {
        fatalError("Failed to copy item: \(error)")
      }

      (recipe as AnyObject).setValue(destURL.path, forKey: "imagePath")
    }
  }

  func application(_ sender: NSApplication, openFile file: String) -> Bool {
    guard let metadata = NSDictionary(contentsOfFile: file) else {
      print("Unable to build dictionary from file")
      return false
    }
    guard let objectIDString = metadata[kPPObjectID] as? String else {
      print("ObjectID was not a string")
      return false
    }
    guard let uri = URL(string: objectIDString) else {
      print("ObjectID could not be formed into a URL")
      return false
    }
    guard let moc = dataController.mainContext else {
      print("Main context is nil")
      return false
    }
    guard let psc = moc.persistentStoreCoordinator else {
      print("PSC is nil")
      return false
    }

    guard let objectID = psc.managedObjectID(forURIRepresentation: uri) else {
      print("ObjectID could not be formed")
      return false
    }

    let recipe = moc.object(with: objectID)

    DispatchQueue.main.async {
      self.recipeArrayController?.setSelectedObjects([recipe])
    }
    return true
  }

}
