//
//  PPRSelectIngredientTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectIngredientTypeViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var managedObjectContext: NSManagedObjectContext?
  var selectIngredientType: ((_ ingredientType: NSManagedObject) -> Void)?
  var fResultsController: NSFetchedResultsController<NSFetchRequestResult>?

  let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()


    navigationItem.rightBarButtonItem = editButtonItem

    let moc = managedObjectContext!
    let psc = moc.persistentStoreCoordinator!
    let model = psc.managedObjectModel
    let name = "allIngredients"
    guard let request = model.fetchRequestTemplate(forName: name) else {
      fatalError("Failed to find fetch request in the model")
    }
    request.sortDescriptors = [NSSortDescriptor(key: "name",
      ascending: true)]

    fResultsController = NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: moc,
      sectionNameKeyPath: nil,
      cacheName: nil)

    fResultsController?.delegate = self

    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Failed to perform fetch: \(error)")
    }
  }

  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)

    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to get row count")
    }
    let iRowPath = IndexPath(row: count, section: 0)

    if editing {
      tableView.deleteRows(at: [iRowPath], with: .fade)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified segue")
    }
    guard let moc = managedObjectContext else {
      fatalError("No MOC assigned")
    }

    assert(identifier == "createIngredientType", "Unexpected identifier")

    switch segue.destination {
    case let controller as PPRCreateIngredientTypeViewController:
      let ingredientType = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: moc)
      controller.ingredientTypeMO = ingredientType
    default: break
    }
    isEditing = false
  }

  //MARK: UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = fResultsController?.sections else {
      fatalError("Unable to retrieve sections from results controller")
    }
    return sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = fResultsController?.sections else {
      fatalError("Unable to retrieve sections from results controller")
    }
    if self.isEditing {
      return sections.count + 1
    } else {
      return sections.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let sections = fResultsController?.sections else {
      fatalError("Unable to retrieve sections from results controller")
    }
    if indexPath.row >= sections.count {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kInsertCellIdentifier) else {
        fatalError("Failed to resolve cell")
      }
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)

    let ingredientType = fResultsController?.object(at: indexPath) as? NSManagedObject
    cell.textLabel?.text = ingredientType?.value(forKey: "name") as? String

    var valueString: String? = currencyFormatter.string(from: 0)
    if let value = ingredientType?.value(forKey: "cost") as? NSNumber {
      valueString = currencyFormatter.string(from: value)
    }

    if let units = ingredientType?.value(forKeyPath: "unitOfMeasure.name") as? String {
      valueString = "\(valueString) per \(units)"
    }

    cell.detailTextLabel?.text = valueString

    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let objectToDelete = fResultsController?.object(at: indexPath) as! NSManagedObject
      managedObjectContext?.delete(objectToDelete)
      return
    }

    performSegue(withIdentifier: "createIngredientType", sender: self)
  }

  //MARK: UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let ingredientType = fResultsController?.object(at: indexPath) as! NSManagedObject
    selectIngredientType?(ingredientType)

    performSegue(withIdentifier: "createIngredientType", sender: self)
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    guard let objects = fResultsController?.fetchedObjects else {
      fatalError("Unable to retrieve sections from results controller")
    }
    if indexPath.row <= objects.count {
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
