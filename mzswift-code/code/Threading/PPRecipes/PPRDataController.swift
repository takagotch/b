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
let FAVORITE_METADATA_KEY = "FAVORITE_METADATA_KEY"

class PPRDataController {
  var mainContext: NSManagedObjectContext?
  var writerContext: NSManagedObjectContext?
  
  init() {
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
    
    var type = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    writerContext = NSManagedObjectContext(concurrencyType: type)
    writerContext?.persistentStoreCoordinator = psc
    
    type = NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType
    mainContext = NSManagedObjectContext(concurrencyType: type)
    mainContext?.parent = writerContext
    
    let queue = DispatchQueue.global(qos: .background)
    queue.async {
      let fileManager = FileManager.default
      guard let documentsURL = fileManager.urls(for: .documentDirectory,
        in: .userDomainMask).first else {
        fatalError("Failed to resolve documents directory")
      }
      let sURL = documentsURL.appendingPathComponent("PPRecipes.sqlite")
      do {
        let store = try psc.addPersistentStore(ofType: NSSQLiteStoreType,
          configurationName: nil, at: sURL, options: nil)
        if store.metadata[FAVORITE_METADATA_KEY] == nil {
          self.bulkUpdateFavorites()
        }
      } catch {
        fatalError("Failed to initialize PSC: \(error)")
      }
      self.populateTypeEntities()
    }
  }
  
  fileprivate func populateTypeEntities() {
    let type = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    let pMOC = NSManagedObjectContext(concurrencyType: type)
    pMOC.parent = mainContext
    pMOC.performAndWait() {
      let fetch = NSFetchRequest<NSManagedObject>(entityName: "Type")
      
      do {
        let count = try pMOC.count(for: fetch)
        if count > 0 { return }
      } catch {
        fatalError("Failed to count receipe types: \(error)")
      }
      
      guard let types = Bundle.main.infoDictionary?[RECIPE_TYPES]
        as? [String] else {
          fatalError("Failed to find default RecipeTypes in Info.plist")
      }
      
      for type in types {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Type",
                                                         into: pMOC)
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
    guard let moc = mainContext else {
      fatalError("save called before mainContext is initialized")
    }
    moc.performAndWait({
      if moc.hasChanges {
        do {
          try moc.save()
        } catch {
          fatalError("Failed to save mainContext: \(error)")
        }
      }
      
      guard let writer = self.writerContext else {
        print("Writer context is nil, skipping")
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
    })
  }
  
  //MARK: Bulk Changes Chapter
  
  func dateFrom1MonthAgo() -> Date {
    let calendar = Calendar.current
    var components = DateComponents()
    components.month = -1
    guard let date = calendar.date(byAdding: components, to: Date(), wrappingComponents:true) else {
      fatalError("Failed to calculate date")
    }
    return date
  }
  
  func dateFrom1YearAgo() -> Date {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = -1
    guard let date = calendar.date(byAdding: components, to: Date(), wrappingComponents: true) else {
      fatalError("Failed to calculate date")
    }
    return date
  }
  
  func manuallyRefreshObjects(_ objectIDArray: [NSManagedObjectID]) {
    guard let moc = mainContext else {
      fatalError("Unexpected nil context")
    }
    moc.performAndWait({
      for objectID in objectIDArray {
        guard let object = moc.registeredObject(for: objectID) else {
          continue
        }
        if object.isFault {
          return
        }
        moc.refresh(object, mergeChanges: true)
        
      }
    })
  }
  
  func mergeExternalChanges(_ objectIDArray: [NSManagedObjectID],
                            ofType type: String) {
    let save = [type: objectIDArray]
    guard let main = mainContext, let writer = writerContext else {
      fatalError("Unexpected nil context")
    }
    let contexts = [main, writer]
    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save,
                                        into: contexts)
  }
  
  func deleteOldRecipes() {
    guard let moc = writerContext else {
      fatalError("Writer context is nil")
    }
    
    moc.perform {
      let yOld = self.dateFrom1YearAgo()
      let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
      fetch.predicate = NSPredicate(format: "lastUsed <= %@", yOld as CVarArg)
      let request = NSBatchDeleteRequest(fetchRequest: fetch)
      request.resultType = .resultTypeObjectIDs
      
      do {
        guard let result = try moc.execute(request)
          as? NSBatchDeleteResult else {
            fatalError("Unexpected result from executeRequest")
        }
        guard let resultArray = result.result as? [NSManagedObjectID] else {
          fatalError("Unexpected result from batchDeleteResult")
        }
        self.mergeExternalChanges(resultArray, ofType: NSDeletedObjectsKey)
      } catch {
        fatalError("error performing delete: \(error)")
      }
    }
  }
  
  func bulkUpdateFavorites() {
    guard let moc = writerContext else {
      fatalError("Writer context is nil")
    }
    moc.perform({
      let request = NSBatchUpdateRequest(entityName: "Recipe")
      let aMAgo = self.dateFrom1MonthAgo()
      let predicate = NSPredicate(format: "lastUsed >= %@", aMAgo as CVarArg)
      request.predicate = predicate
      request.propertiesToUpdate = ["favorite":true]
      request.resultType = .updatedObjectIDsResultType
      do {
        guard let result = try moc.execute(request)
          as? NSBatchUpdateResult else {
            fatalError("Unexpected result from executeRequest")
        }
        guard let resultArray = result.result as? [NSManagedObjectID] else {
          fatalError("Unexpected result from batchUpdateResult")
        }
        self.mergeExternalChanges(resultArray, ofType: NSUpdatedObjectsKey)
      } catch {
        fatalError("Failed to execute request: \(error)")
      }
      
      if let store = moc.persistentStoreCoordinator?.persistentStores.last {
        var metadata = store.metadata
        metadata?[FAVORITE_METADATA_KEY] = true
        store.metadata = metadata
      }
    })
  }
}
