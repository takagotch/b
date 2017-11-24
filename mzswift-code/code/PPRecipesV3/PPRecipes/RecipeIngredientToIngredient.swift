//
//  RecipeIngredientToIngredient.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/14/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

class RecipeIngredientToIngredient: NSEntityMigrationPolicy {

  override func createDestinationInstances(forSource s: NSManagedObject,
    in mapping: NSEntityMapping,
    manager: NSMigrationManager) throws {
    let destMOC = manager.destinationContext
    guard let dEntityName = mapping.destinationEntityName else {
      fatalError("Destination entity name is nil")
    }

    guard let name = s.value(forKey: "name") as? String else {
      fatalError("Source object did not have a value for 'name'")
    }

    var userInfo: [AnyHashable: Any]
    if let managerUserInfo = manager.userInfo {
      userInfo = managerUserInfo
    } else {
      userInfo = [AnyHashable: Any]()
    }

    var ingredientLookup: [String:NSManagedObject]!
    if let lookup = userInfo["ingredients"] as? [String:NSManagedObject] {
      ingredientLookup = lookup
    } else {
      ingredientLookup = [String:NSManagedObject]()
      userInfo["ingredients"] = ingredientLookup
    }

    var uofmLookup: [String:NSManagedObject]!
    if let lookup = userInfo["unitOfMeasure"] as? [String:NSManagedObject] {
      uofmLookup = lookup
    } else {
      uofmLookup = [String:NSManagedObject]()
      userInfo["unitOfMeasure"] = uofmLookup
    }

    var dest = ingredientLookup[name]
    if dest == nil {
      dest = NSEntityDescription.insertNewObject(forEntityName: dEntityName,
        into: destMOC)
      dest!.setValue(name, forKey:"name")
      ingredientLookup[name] = dest

      guard let uofmName = s.value(forKey: "unitOfMeasure") as? String else {
        fatalError("Unit of Measure name is nil")
      }
      var uofm = uofmLookup[uofmName]
      if uofm == nil {
        let eName = "UnitOfMeasure"
        uofm = NSEntityDescription.insertNewObject(forEntityName: eName,
          into: destMOC)
        uofm!.setValue(uofmName, forKey:"name")
        dest!.setValue(uofm, forKey:"unitOfMeasure")
        uofmLookup[name] = uofm
      }
    }
    manager.userInfo = userInfo
  }

  override func createRelationships(forDestination d: NSManagedObject,
    in mapping: NSEntityMapping,
    manager: NSMigrationManager) throws {
  }
}
