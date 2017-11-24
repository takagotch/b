//
//  PPRDataController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let RECIPE_TYPES = "ppRecipeTypes"

class PPRDataController : NSObject {
  var mainContext: NSManagedObjectContext?
  var writerContext: NSManagedObjectContext?
  var managedDocument: UIManagedDocument?
  var persistenceInitialized = false
  var initializationComplete: (() -> Void)?

  init(completion: @escaping () -> Void) {
    super.init()
    initializationComplete = completion
    initializeCoreDataStack()
  }

  func initializeCoreDataStackALT() {
    guard let modelURL = Bundle.main.url(forResource: "PPRecipes",
      withExtension: "momd") else {
      fatalError("Failed to locate DataModel.momd in app bundle")
    }
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to initialize MOM")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

    var type = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    writerContext = NSManagedObjectContext(concurrencyType: type)
    writerContext?.persistentStoreCoordinator = psc

    type = NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType
    mainContext = NSManagedObjectContext(concurrencyType: type)
    mainContext?.parent = writerContext

    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      let fileManager = FileManager.default
      guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        fatalError("Failed to resolve documents directory")
      }
      let storeURL = documentsURL.appendingPathComponent("PPRecipes.sqlite")

      do {
        try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
      } catch {
        fatalError("Failed to initialize PSC: \(error)")
      }
      self.populateTypeEntities()
      self.persistenceInitialized = true
    }
  }

  func initializeCoreDataStack() {
    guard let modelURL = Bundle.main.url(forResource: "PPRecipes", withExtension: "momd") else {
      fatalError("Failed to locate DataModel.momd in app bundle")
    }
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to initialize MOM")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

    mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainContext?.persistentStoreCoordinator = psc

    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      let fileManager = FileManager.default
      guard let docURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
        fatalError("Failed to resolve documents directory")
      }
      let storeURL = docURL.appendingPathComponent("PPRecipes.sqlite")
      do {
        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
          configurationName: nil, at: storeURL, options: nil)
      } catch {
        fatalError("Failed to initialize PSC: \(error)")
      }
      self.populateTypeEntities()
      self.persistenceInitialized = true
      if let closure = self.initializationComplete {
        DispatchQueue.main.async {
          closure()
        }
      }
    }
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(mergePSCChanges(_:)),
      name: .NSPersistentStoreDidImportUbiquitousContentChanges,
      object: mainContext)
  }

  func initializeCoreDataStack2() {
    guard let modelURL = Bundle.main.url(forResource: "PPRecipes",
                                         withExtension: "momd") else {
      fatalError("Failed to locate DataModel.momd in app bundle")
    }
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to initialize MOM")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

    mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainContext?.persistentStoreCoordinator = psc

    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      let fileManager = FileManager.default
      guard let docURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
          fatalError("Failed to resolve documents directory")
      }

      var options = [String:Any]()
      options[NSMigratePersistentStoresAutomaticallyOption] = true
      options[NSInferMappingModelAutomaticallyOption] = true

      let aCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)

      guard let cloudURL = aCloudURL else {
        let storeURL = docURL.appendingPathComponent("PPRecipes.sqlite")
        do {
          try psc.addPersistentStore(ofType: NSSQLiteStoreType,
            configurationName: nil, at: storeURL, options: options)
        } catch {
          fatalError("Failed to initialize PSC: \(error)")
        }
        if let closure = self.initializationComplete {
          DispatchQueue.main.async {
            closure()
          }
        }
        return
      }

      let filename = "PPRecipes-iCloud.sqlite"
      let storeURL = docURL.appendingPathComponent(filename)
      let oldURL = docURL.appendingPathComponent("PPRecipes.sqlite")
      let oldURLPath = oldURL.path
      var store: NSPersistentStore? = nil
      if fileManager.fileExists(atPath: oldURLPath) {
        do {
          store = try psc.addPersistentStore(ofType: NSSQLiteStoreType,
            configurationName: nil, at: oldURL, options: options)
        } catch {
          fatalError("Error adding store to PSC:\(error)")
        }
      }

      guard let identifier = Bundle.main.bundleIdentifier else {
        fatalError("BundleIdentifier is nil")
      }
      options[NSPersistentStoreUbiquitousContentNameKey] = identifier
      options[NSPersistentStoreUbiquitousContentURLKey] = cloudURL

      do {
        try psc.migratePersistentStore(store!, to: storeURL,
          options: options, withType: NSSQLiteStoreType)
      } catch {
        fatalError("Failed to migrate store: \(error)")
      }

      if let closure = self.initializationComplete {
        DispatchQueue.main.async {
          closure()
        }
      }
    }
  }

  func mergePSCChanges(_ notification: Notification) {
    guard let moc = self.mainContext else {
      fatalError("Unexpected nil MOC")
    }
    moc.perform() {
      moc.mergeChanges(fromContextDidSave: notification)
    }
  }

  func initializeDocument() {
    let queue = DispatchQueue.global(qos: .background)

    queue.async {
      let fileManager = FileManager.default
      guard let documentsURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
        fatalError("Failed to resolve documents directory")
      }
      let storeURL = documentsURL.appendingPathComponent("PPRecipes")

      var options = [String:Any]()
      options[NSMigratePersistentStoresAutomaticallyOption] = true
      options[NSInferMappingModelAutomaticallyOption] = true

      if let cloudURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
        let url = cloudURL.appendingPathComponent("PPRecipes")
        let identifier = Bundle.main.bundleIdentifier
        options[NSPersistentStoreUbiquitousContentNameKey] = identifier
        options[NSPersistentStoreUbiquitousContentURLKey] = url
      }

      let document = UIManagedDocument(fileURL: storeURL)
      document.persistentStoreOptions = options

      let type = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType
      let policy = NSMergePolicy(merge: type)
      document.managedObjectContext.mergePolicy = policy

      let completion: (Bool) -> Void = { (success:Bool) -> Void in
        if !success {
          print("Failed to open file: \(storeURL)")
          return
        }

        if let closure = self.initializationComplete {
          DispatchQueue.main.async {
            closure()
          }
        }
      }

      self.managedDocument = document

      let path = storeURL.path

      if FileManager.default.fileExists(atPath: path) {
        document.open(completionHandler: completion)
      } else {
        document.save(to: storeURL, for: .forCreating,
          completionHandler: completion)
      }

      let center = NotificationCenter.default
      center.addObserver(self,
        selector: #selector(PPRDataController.documentStateChanged(_:)),
        name: NSNotification.Name.UIDocumentStateChanged, object: document)
    }
  }

  func saveDocument() {
    guard let fileURL = managedDocument?.fileURL else {
      fatalError("document did not have a URL")
    }
    managedDocument?.save(to: fileURL, for: .forOverwriting,
      completionHandler: { (success) in
        //Handle failure
    })
  }

  func documentStateChanged(_ notification: Notification) {
    guard let doc = notification.object as? UIManagedDocument else {
      fatalError("Unexpected object in notification")
    }
    switch doc.documentState {
    case UIDocumentState():
      print("UIDocumentStateNormal: \(notification)")
    case UIDocumentState.closed:
      print("UIDocumentStateClosed: \(notification)")
    case UIDocumentState.inConflict:
      print("UIDocumentStateInConflict: \(notification)")
    case UIDocumentState.savingError:
      print("UIDocumentStateSavingError: \(notification)")
    case UIDocumentState.editingDisabled:
      print("UIDocumentStateDisabled: \(notification)")
    case UIDocumentState.progressAvailable:
      print("UIDocumentStateProgressAvailable: \(notification)")
    default: break
    }
  }

  fileprivate func populateTypeEntities() {
    let pMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    pMOC.parent = mainContext
    pMOC.performAndWait() {
      let fetch = NSFetchRequest<NSManagedObject>(entityName: "Type")

      do {
        let count = try pMOC.count(for: fetch)
        if count > 0 { return }
      } catch {
        fatalError("Failed to count receipe types: \(error)")
      }

      guard let types = Bundle.main.infoDictionary?[RECIPE_TYPES] as? [String] else {
        fatalError("Failed to find default RecipeTypes in Info.plist")
      }

      for type in types {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Type", into: pMOC)
        object.setValue(type, forKey:"name")
      }

      do {
        try pMOC.save()
      } catch {
        fatalError("Failed to save private child moc: \(error)")
      }
    }
  }

  func saveContext() {
    guard let main = mainContext else {
      fatalError("save called before mainContext is initialized")
    }
    main.performAndWait({
      if !main.hasChanges { return }
      do {
        try main.save()
      } catch {
        fatalError("Failed to save mainContext: \(error)")
      }
    })
    guard let writer = writerContext else {
      return
    }
    writer.perform({
      if !writer.hasChanges { return }
      do {
        try writer.save()
      } catch {
        fatalError("Failed to save writerContext: \(error)")
      }
    })
  }
}
