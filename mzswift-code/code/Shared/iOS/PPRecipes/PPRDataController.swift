//
//  PPRDataController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

let RECIPE_TYPES = "ppRecipeTypes"

class PPRDataController: NSObject {
  var mainContext: NSManagedObjectContext?
  var writerContext: NSManagedObjectContext?
  var persistenceInitialized = false
  var initializationComplete: ((Error?) -> Void)?

  init(completion: @escaping (Error?) -> Void) {
    super.init()
    initializationComplete = completion
    initializeCoreDataStack()
  }

  func initializeCoreDataStack() {
    guard let modelURL = Bundle.main.url(forResource: "PPRecipes",
      withExtension: "momd") else {
        fatalError("Failed to locate DataModel.momd in app bundle")
    }
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to initialize MOM")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

    let type = NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType
    mainContext = NSManagedObjectContext(concurrencyType: type)
    mainContext?.persistentStoreCoordinator = psc

    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      let fileManager = FileManager.default
      guard let documentsURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
          fatalError("Failed to resolve documents directory")
      }
      let storeURL = documentsURL.appendingPathComponent("PPRecipes.sqlite")

      do {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
          NSInferMappingModelAutomaticallyOption: true]
        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
          configurationName: nil, at: storeURL, options: options)
      } catch let error {
        assertionFailure("Failed to add persistent store: \(error)")
        self.initializationComplete?(error)
      }
      self.populateTypeEntities()
      self.persistenceInitialized = true
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

