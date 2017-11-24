//
//  PPRCreateIngredientTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRCreateIngredientTypeViewController: UITableViewController {
  var ingredientTypeMO: NSManagedObject?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified segue")
    }
    
    switch identifier {
    case "setName":
      guard let controller = segue.destination as? PPRTextEditViewController else {
        fatalError("Unexpected controller type")
      }
      controller.text = ingredientTypeMO?.value(forKey: "name") as? String
      controller.textChangedClosure = { (text: String) in
        let path = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: path)
        cell?.detailTextLabel?.text = text
        self.ingredientTypeMO?.setValue(text, forKey: "name")
      }
    case "setValue":
      guard let controller = segue.destination as? PPRTextEditViewController else {
        fatalError("Unexpected controller type")
      }
      controller.text = (ingredientTypeMO?.value(forKey: "cost") as? NSNumber)?.stringValue
      controller.textChangedClosure = { (text: String) in
        let numberFormatter = NumberFormatter()
        guard let value = numberFormatter.number(from: text) else {
          throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid value"])
        }
        
        let path = IndexPath(row: 1, section: 0)
        let cell = self.tableView.cellForRow(at: path)
        cell?.detailTextLabel?.text = text
        self.ingredientTypeMO?.setValue(value, forKey: "cost")
      }
    case "selectUnitOfMeasure":
      guard let controller = segue.destination as? PPRSelectUnitOfMeasureViewController else {
        fatalError("Unexpected controller type")
      }
      controller.selectUnitOfMeasure = { (unit: NSManagedObject) in
        self.ingredientTypeMO?.setValue(unit, forKey: "unitOfMeasure")
        
        let path = IndexPath(row: 2, section: 0)
        let cell = self.tableView.cellForRow(at: path)
        cell?.detailTextLabel?.text = unit.value(forKey: "name") as? String
      }
    default:
      print("Unrecognized identifier: \(identifier)")
    }
  }
  
  func cancel(sender: AnyObject) {
    if let moc = ingredientTypeMO?.managedObjectContext {
      moc.delete(ingredientTypeMO!)
    }
    navigationController!.popViewController(animated: true)
  }
  
  func save(sender: AnyObject) {
    navigationController!.popViewController(animated: true)
  }
}
