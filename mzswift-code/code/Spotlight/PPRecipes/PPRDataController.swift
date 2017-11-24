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
      guard let docURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
          fatalError("Failed to resolve documents directory")
      }
      let sURL = docURL.appendingPathComponent("PPRecipes.sqlite")

      do {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
          NSInferMappingModelAutomaticallyOption: true]
        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
          configurationName: nil, at: sURL, options: options)
      } catch let error {
        assertionFailure("Failed to add persistent store: \(error)")
        self.initializationComplete?(error)
      }
      self.populateTypeEntities()
      self.persistenceInitialized = true
      queue.async {
        self.verifyAndUpdateMetadata()
      }
    }
  }

  fileprivate func verifyAndUpdateMetadata() {
    let path = metadataFolderURL.path
    if FileManager.default.fileExists(atPath: path) { return }
    let t = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    let child = NSManagedObjectContext(concurrencyType: t)
    child.perform {
      let fetch = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
      do {
        let r = try child.fetch(fetch)
        self.updateMetadataForObjects(r, andDeletedObjects: [])
      } catch {
        fatalError("Failed to retrieve recipes: \(error)")
      }
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
      if !main.hasChanges {
        return
      }
      let recipeFilter = { (mo:NSManagedObject) -> Bool in
        if mo.isKind(of: PPRRecipeMO.self) {
          return true
        } else {
          return false
        }
      }
      let deleted = main.deletedObjects.filter(recipeFilter).map {
        (mo) -> String in
        return mo.value(forKey: "metadataFilename") as! String
      }
      var existing = [NSManagedObject]()
      existing.append(contentsOf: main.insertedObjects.filter(recipeFilter))
      existing.append(contentsOf: main.updatedObjects.filter(recipeFilter))
      do {
        try main.save()
        self.updateMetadataForObjects(existing, andDeletedObjects:deleted)
      } catch {
        fatalError("Failed to save mainContext: \(error)")
      }
    })
  }

  func updateMetadataForObjects(_ existing: [NSManagedObject],
    andDeletedObjects deleted:[String]) {
    print("updateMetadataForObjects entered")
    if existing.count == 0 && deleted.count == 0 { return }

    let fileManager = FileManager.default

    do {
      try fileManager.createDirectory(at: metadataFolderURL,
        withIntermediateDirectories: true, attributes: nil)
    } catch let error {
      if error.code != 518 { //Expected error
        fatalError("Unexpected error creating metadata: \(error)")
      }
    }
    for path in deleted {
      let fileURL = metadataFolderURL.appendingPathComponent(path)
      do {
        try fileManager.removeItem(at: fileURL)
      } catch {
        print("Error deleting: \(error)")
      }
    }
    let attributes = [FileAttributeKey.extensionHidden:true]
    for object in existing {
      guard let recipe = object as? PPRRecipeMO else {
        fatalError("Non-recipe unexpected")
      }
      let metadata = recipe.metadata()
      let filename = recipe.metadataFilename()
      let fileURL = metadataFolderURL.appendingPathComponent(filename)
      let path = fileURL.path
      metadata.write(toFile: path, atomically:true)
      do {
        try fileManager.setAttributes(attributes, ofItemAtPath: path)
      } catch {
        fatalError("Failed to update attributes: \(error)")
      }
    }
  }

  func persistentStoreCoordinator() -> NSPersistentStoreCoordinator {
    return mainContext!.persistentStoreCoordinator!
  }

  var metadataFolderURL: URL = {
    guard var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
      .userDomainMask, true).last else {
      fatalError("Failed to resolve cache directory")
    }
    guard var url = URL(string: path) else { fatalError("Failed to construct url") }
    url = url.appendingPathComponent("Metadata")
    url = url.appendingPathComponent("GrokkingRecipes")
    return url
  }()


}
