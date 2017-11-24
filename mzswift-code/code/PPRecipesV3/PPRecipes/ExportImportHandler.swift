//
//  ExportImportHandler.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/10/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

let PPExportRelationship = "PPExportRelationship"

class PPRExportOperation: Operation {
  let parentContext: NSManagedObjectContext
  let recipeID: NSManagedObjectID
  let handler: (_ data: Data?, _ error: Error?) -> Void

  init(_ aRecipe: PPRRecipeMO, completionHandler aHandler: @escaping (_ data: Data?,
    _ error: Error?) -> Void) {

    guard let moc = aRecipe.managedObjectContext else {
      fatalError("Recipe has no context")
    }
    self.parentContext = moc
    recipeID = aRecipe.objectID
    handler = aHandler
    super.init()
  }

  override func main() {
    let type = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    let localMOC = NSManagedObjectContext(concurrencyType: type)
    localMOC.parent = parentContext

    localMOC.performAndWait({
      let localRecipe = localMOC.object(with: self.recipeID)

      let json = self.moToDictionary(localRecipe)
      do {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        DispatchQueue.main.async {
          self.handler(data, nil)
        }
      } catch let error {
        DispatchQueue.main.async {
          self.handler(nil, error)
        }
      }
    })
  }

  func moToDictionary(_ mo: NSManagedObject) -> [String:AnyObject] {
    var dict = [String:AnyObject]()
    let entity = mo.entity

    for (key, value) in entity.attributesByName {
      dict[key] = value
    }
    let relationships = entity.relationshipsByName
    for (name, relDesc) in relationships {
      if let skip = relDesc.userInfo?[PPExportRelationship] as? NSString {
        if skip.boolValue {
          continue
        }
      }
      if relDesc.isToMany {
        if let children = mo.value(forKey: name) as? [NSManagedObject] {
          var array = [[String:AnyObject]]()
          for childMO in children {
            array.append(moToDictionary(childMO))
          }
          dict[name] = array as AnyObject?
        }
      } else {
        if let childMO = mo.value(forKey: name) as? NSManagedObject {
          dict[name] = moToDictionary(childMO) as AnyObject?
        }
      }
    }

    return dict
  }
}

class PPRImportOperation: Operation {
  let incomingData: Data
  let parentContext: NSManagedObjectContext

  init(data: Data, context: NSManagedObjectContext,
    handler: (_ error: Error?) -> Void) {
    incomingData = data
    parentContext = context
    super.init()
  }

  override func main() {
    let type = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    let localMOC = NSManagedObjectContext(concurrencyType: type)
    localMOC.parent = parentContext

    localMOC.performAndWait({
      do {
        try self.processRecipeIntoContext(localMOC)

        try localMOC.save()
      } catch {
        fatalError("Failed to import: \(error)")
      }
    })
  }

  func processRecipeIntoContext(_ moc: NSManagedObjectContext) throws {
    let json = try JSONSerialization.jsonObject(with: incomingData,
      options: [])

    guard let entity = NSEntityDescription.entity(forEntityName: "Recipe",
      in: moc) else {
      fatalError("Unable to resolve Recipe")
    }

    switch json {
    case let single as [String:AnyObject]:
      let recipe = NSManagedObject(entity: entity,
        insertInto: moc)
      populateFromDictionary(single, withMO: recipe)
    case let array as [[String:AnyObject]]:
      for recipeJSON in array {
        let recipe = NSManagedObject(entity: entity,
          insertInto: moc)
        populateFromDictionary(recipeJSON, withMO: recipe)
      }
    default: break
    }
  }

  func populateFromDictionary(_ incoming: [String: AnyObject],
    withMO object:NSManagedObject) {

    let entity = object.entity
    for (key, _) in entity.attributesByName {
      object.setValue(incoming[key], forKey:key)
    }

    guard let moc = object.managedObjectContext else {
      fatalError("No context available")
    }
    let createChild: (_ childDict: [String:AnyObject],
      _ entity:NSEntityDescription,
      _ moc:NSManagedObjectContext) -> NSManagedObject = {
      (childDict, entity, moc) in
      let destMO = NSManagedObject(entity: entity,
        insertInto: moc)
      self.populateFromDictionary(childDict, withMO: destMO)
      return destMO
    }

    for (name, relDesc) in entity.relationshipsByName {
      let childStructure = incoming[name]
      if childStructure == nil {
        continue
      }
      guard let destEntity = relDesc.destinationEntity else {
        fatalError("no destination entity assigned")
      }
      if relDesc.isToMany {
        guard let childArray = childStructure as? [[String: AnyObject]] else {
          fatalError("To many relationship with malformed JSON")
        }
        var children = [NSManagedObject]()
        for child in childArray {
          let mo = createChild(child, destEntity, moc)
          children.append(mo)
        }
        object.setValue(children, forKey: name)
      } else {
        guard let child = childStructure as? [String: AnyObject] else {
          fatalError("To many relationship with malformed JSON")
        }
        let mo = createChild(child, destEntity, moc)
        object.setValue(mo, forKey: name)
      }
    }
  }
}



