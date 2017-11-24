//
//  PPREditIngredientListViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPREditIngredientListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var fResultsController: NSFetchedResultsController<NSManagedObject>?
  var recipeMO: NSManagedObject?
  var updateIngredientCountBlock: ((_ ingredientCount: Int) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = editButtonItem
    
    guard let mo = recipeMO else {
      fatalError("Failed to set managed object")
    }
    let fetch = NSFetchRequest<NSManagedObject>(entityName: "RecipeIngredient")
    fetch.predicate = NSPredicate(format: "recipe == %@", mo)
    fetch.sortDescriptors = [NSSortDescriptor(key: "ingredient.name", ascending: true)]
    
    guard let moc = mo.managedObjectContext else {
      fatalError("managed object is not assigned to a context")
    }
    fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    fResultsController?.delegate = self
    
    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Failed to execute fetch: \(error)")
    }
    
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Unable to retrieve fetchedObjects")
    }
    let path = IndexPath(row: count, section: 0)
    
    if editing {
      tableView.insertRows(at: [path], with: .fade)
    } else {
      tableView.deleteRows(at: [path], with: .fade)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unknown segue")
    }
    assert(identifier == "addIngredient", "Unexpected segue: \(identifier)")
    guard let controller = segue.destination as? PPRAddRecipeIngredientViewController else {
      fatalError("Unexpected destination view controller: \(segue.destination.self)")
    }
    
    guard let moc = recipeMO?.managedObjectContext else {
      fatalError("failed to retrieve context")
    }
    let recipeIngredient = NSEntityDescription .insertNewObject(forEntityName: "RecipeIngredient", into: moc)
    controller.recipeIngredientMO = recipeIngredient
    isEditing = false
  }
  
  //MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count = fResultsController?.sections?[section].numberOfObjects else {
      fatalError("Failed to retrieve section count")
    }
    if isEditing {
      return count + 1
    } else {
      return count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let count = fResultsController?.sections?[indexPath.row].numberOfObjects else {
      fatalError("Failed to retrieve section count")
    }
    if indexPath.row >= count {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kInsertCellIdentifier) else {
        fatalError("Failed to retrieve cell for identifier: \(kInsertCellIdentifier)")
      }
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
    guard let ingredient = fResultsController?.object(at: indexPath) else {
      fatalError("Failed to retrieve object")
    }
    cell.textLabel?.text = ingredient.value(forKeyPath: "ingredient.name") as? String
    
    let quantity = ingredient.value(forKey: "quantity")
    let unit = ingredient.value(forKeyPath: "ingredient.unitOfMeasure.name")
    cell.detailTextLabel?.text = "\(quantity) \(unit)"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .insert {
      performSegue(withIdentifier: "addIngredient", sender: self)
      return
    }
    
    guard let mo = fResultsController?.object(at: indexPath), let moc = fResultsController?.managedObjectContext else {
      fatalError("Failed to retrieve object or context")
    }
    moc.delete(mo)
  }
  
  //MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    guard let count = fResultsController?.sections?[indexPath.row].numberOfObjects else {
      fatalError("Failed to retrieve section count")
    }
    if indexPath.row >= count {
      return .insert
    }
    return .delete
  }
  
  //MARK: NSFetchedResultsControllerDelegate
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    default: break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .fade)
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
