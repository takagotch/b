//
//  PPRAddRecipeIngredientViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRAddRecipeIngredientViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  var recipeIngredientMO: NSManagedObject!
  
  func populateViewFromObject() {
    var cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
    if let value = recipeIngredientMO.value(forKey: "quantity") {
      cell?.detailTextLabel?.text = value as? String
    } else {
      cell?.detailTextLabel?.text = "0"
    }
    cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
    if let value = recipeIngredientMO.value(forKey: "name") {
      cell?.detailTextLabel?.text = value as? String
    } else {
      cell?.detailTextLabel?.text = ""
    }
    cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0))
    if let value = recipeIngredientMO.value(forKey: "unitOfMeasure") {
      cell?.detailTextLabel?.text = value as? String
    } else {
      cell?.detailTextLabel?.text = ""
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    populateViewFromObject()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { fatalError("Segue without an identifier") }
    guard let controller = segue.destination as? PPRTextEditViewController else { fatalError("Wrong destination view controller") }
    
    switch identifier {
    case "setQuantity":
      let quantity = recipeIngredientMO.value(forKey: "quantity") as! NSNumber
      controller.text = quantity.stringValue
      controller.textChangedClosure = {
        (newText: String) in
        let numberFormatter = NumberFormatter()
        guard let quantity = numberFormatter.number(from: newText) else {
          let userInfo = [NSLocalizedDescriptionKey: "Invalid quantity"]
          throw NSError(domain: "PragProg", code: 1123, userInfo: userInfo)
        }
        self.recipeIngredientMO.setValue(quantity, forKey: "quantity")
      }
    case "setType":
      let type = recipeIngredientMO.value(forKey: "name") as! String
      controller.text = type
      controller.textChangedClosure = {
        (newText: String) in
        self.recipeIngredientMO.setValue(type, forKey: "name")
      }
    case "setUnits":
      let type = recipeIngredientMO.value(forKey: "unitOfMeasure") as! String
      controller.text = type
      controller.textChangedClosure = {
        (newText: String) in
        self.recipeIngredientMO.setValue(type, forKey: "unitOfMeasure")
      }
    default:
      print("Unknown identifier: \(identifier)")
    }
    populateViewFromObject()
  }
  
  func save(_ sender: AnyObject) {
    navigationController!.popViewController(animated: true)
  }
  
  func cancel(_ sender: AnyObject) {
    let moc = recipeIngredientMO.managedObjectContext
    moc?.delete(recipeIngredientMO)
    navigationController!.popViewController(animated: true)
  }
}
