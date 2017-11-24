//
//  PPREditRecipeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPREditRecipeViewController: UITableViewController {
  var recipeMO: PPRRecipeMO?
  
  func populateTableData() {
    var index = 0
    
    while index <= 6 {
      let path = IndexPath(row: index, section: 0)
      let cell = tableView.cellForRow(at: path)
      switch index {
      case 0:
        if let name = recipeMO?.value(forKey: "name") as? String {
          cell?.detailTextLabel?.text = name
        }
      case 1:
        if let type = recipeMO?.value(forKey: "type") as? String {
          cell?.detailTextLabel?.text = type
        }
      case 2:
        if let serves = recipeMO?.value(forKey: "serves") as? String {
          cell?.detailTextLabel?.text = serves
        }
      case 3:
        if let lastUsed = recipeMO?.lastUsedString() {
          cell?.detailTextLabel?.text = lastUsed
        }
      case 4:
        if let author = recipeMO?.value(forKeyPath: "author.name") as? String {
          cell?.detailTextLabel?.text = author
        }
      case 5:
        guard let textView = cell?.viewWithTag(1123) as? UITextField else {
          fatalError("Failed to find textField")
        }
        if let desc = recipeMO?.value(forKey: "desc") as? String {
          textView.text = desc
        }
      case 6:
        if let objects = recipeMO?.value(forKey: "ingredients") as? [NSManagedObject] {
          cell?.detailTextLabel?.text = "\(objects.count)"
        }
        
      default:
        fatalError("Bad index: \(index)")
      }
      index += 1
    }
  }
  
  @IBAction func save(sender: AnyObject) {
    //MSZ ToDo
    
    navigationController!.popViewController(animated: true)
  }
  
  @IBAction func cancel(sender: AnyObject) {
    guard let mo = recipeMO else {
      fatalError("recipe is nil")
    }
    guard let moc = mo.managedObjectContext else {
      fatalError("recipe is not associated with a context")
    }
    if mo.isInserted {
      moc.delete(mo)
    } else {
      moc.refresh(mo, mergeChanges: false)
    }
    
    navigationController!.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified segue")
    }
    switch identifier {
    case "editRecipeName":
      guard let controller = segue.destination as? PPRTextEditViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForEditRecipeNameSegue(controller)
    case "selectRecipeType":
      guard let controller = segue.destination as? PPRSelectTypeViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForSelectTypeSegue(controller)
    case "selectNumberOfServings":
      guard let controller = segue.destination as? PPRTextEditViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForSetServingsSegue(controller)
    case "selectLastUsed":
      guard let controller = segue.destination as? PPRSetDateViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForSetDateSegue(controller)
    case "selectAuthor":
      guard let controller = segue.destination as? PPRSelectAuthorViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForSelectAuthorSegue(controller)
      print("")
    case "selectIngredients":
      guard let controller = segue.destination as? PPREditIngredientListViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForSelectIngredientSegue(controller)
    case "editDescription":
      guard let controller = segue.destination as? PPRTextEditViewController else {
        fatalError("Unexpected view controller in segue")
      }
      prepareForDirectionsSegue(controller)
    default:
      fatalError("Unrecognized segue: \(identifier)")
    }
  }
  
  func prepareForSelectIngredientSegue(_ controller: PPREditIngredientListViewController) {
    controller.recipeMO = recipeMO
    
    controller.updateIngredientCountBlock = { (ingredientCount: Int) in
      let path = IndexPath(row: 6, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = "\(ingredientCount)"
    }
  }
  
  func prepareForSelectAuthorSegue(_ controller: PPRSelectAuthorViewController) {
    controller.managedObjectContext = recipeMO?.managedObjectContext
    controller.selectAuthorClosure = { (authorMO: NSManagedObject) in
      let path = IndexPath(row: 4, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      self.recipeMO?.setValue(authorMO, forKey: "author")
      cell?.detailTextLabel?.text = authorMO.value(forKey: "name") as? String
    }
  }
  
  func prepareForSetDateSegue(_ controller: PPRSetDateViewController) {
    if let date = recipeMO?.value(forKey: "lastUsed") as? Date {
      controller.datePicker?.date = date
    }
    
    controller.dateChangedClosure = { (newDate: Date) in
      self.recipeMO?.setValue(newDate, forKey: "lastUsed")
      let path = IndexPath(row: 3, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = self.recipeMO?.lastUsedString()
    }
  }
  
  func prepareForSetServingsSegue(_ controller: PPRTextEditViewController) {
    if let number = recipeMO?.value(forKey: "serves") as? NSNumber {
      controller.text = number.stringValue
    } else {
      controller.text = "0"
    }
    
    controller.textChangedClosure = { (text: String) in
      let numberFormatter = NumberFormatter()
      guard let servings = numberFormatter.number(from: text) else {
        throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid servings"])
      }
      
      self.recipeMO?.setValue(servings, forKey: "serves")
      let path = IndexPath(row: 2, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = text
    }
  }
  
  func prepareForSelectTypeSegue(_ controller: PPRSelectTypeViewController) {
    controller.managedObjectContext = recipeMO?.managedObjectContext
    controller.typeChangedClosure = { (text: String) in
      self.recipeMO?.setValue(text, forKey: "type")
      let path = IndexPath(row: 1, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = text
    }
  }
  
  func prepareForEditRecipeNameSegue(_ controller: PPRTextEditViewController) {
    controller.text = recipeMO?.value(forKey: "name") as? String
    
    controller.textChangedClosure = { (text: String) in
      self.recipeMO?.setValue(text, forKey: "name")
      let path = IndexPath(row: 0, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = text
    }
  }
  
  func prepareForDirectionsSegue(_ controller: PPRTextEditViewController) {
    controller.text = recipeMO?.value(forKey: "desc") as? String
    
    controller.textChangedClosure = { (text: String) in
      self.recipeMO?.setValue(text, forKey: "desc")
      let path = IndexPath(row: 5, section: 0)
      let cell = self.tableView.cellForRow(at: path)
      cell?.detailTextLabel?.text = text
    }
  }
}
