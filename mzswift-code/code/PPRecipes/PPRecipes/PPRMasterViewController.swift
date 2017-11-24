//
//  PPREntryViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRMasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var managedObjectContext: NSManagedObjectContext?
  var fResultsController: NSFetchedResultsController<NSManagedObject>?
  var detailController: PPRDetailViewController?

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = editButtonItem

    if let navController = splitViewController?.viewControllers.last as? UINavigationController {
      detailController = navController.topViewController as? PPRDetailViewController
    }

    let fetch = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
    fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

    guard let moc = managedObjectContext else {
      fatalError("MOC not initialized")
    }
    fResultsController = NSFetchedResultsController(fetchRequest: fetch,
      managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    fResultsController?.delegate = self
    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Unable to fetch: \(error)")
    }
  }

  func frcExmaple2() {
    let fetch = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
    fetch.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true),
      NSSortDescriptor(key: "name", ascending: true)]

    guard let moc = managedObjectContext else {
      fatalError("MOC not initialized")
    }
    fResultsController = NSFetchedResultsController(fetchRequest: fetch,
      managedObjectContext: moc, sectionNameKeyPath: "type",
      cacheName: "Master")
    fResultsController?.delegate = self
    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Unable to fetch: \(error)")
    }
  }

  func prepareForDetailSegue(_ segue: UIStoryboardSegue) {
    let control = segue.destination as! PPRDetailViewController
    let path = tableView.indexPathForSelectedRow!
    let recipe = fResultsController!.object(at: path) as! PPRRecipeMO
    control.recipeMO = recipe
  }

  func prepareForAddRecipeSegue(_ segue: UIStoryboardSegue) {
    let tempController = segue.destination
    let controller = tempController as! PPREditRecipeViewController
    let moc = managedObjectContext!
    let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe",
      into: moc) as! PPRRecipeMO
    controller.recipeMO = recipe
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified segue")
    }

    switch identifier {
    case "showRecipe":
      prepareForDetailSegue(segue)
    case "addRecipe":
      prepareForAddRecipeSegue(segue)
    default:
      fatalError("Unexpected segue: \(identifier)")
    }
  }

  //MARK UITableViewDelegate

  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let count = fResultsController?.sections?.count else {
      fatalError("Failed to resolve FRC")
    }
    return count
  }

  override func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fResultsController?.sections?[section] else {
      fatalError("Failed to resolve FRC")
    }
    return sectionInfo.numberOfObjects
  }

  override func tableView(_ tableView: UITableView,
    canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let frc = fResultsController else {
      fatalError("Failed to resolve NSFetchedResultsController")
    }
    let obj = frc.object(at: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        else {
      fatalError("Failed to dequeue cell")
    }
    cell.textLabel?.text = obj.value(forKey: "name") as? String
    return cell
  }

  //MARK: NSFetchedResultsControllerDelegate

  func controllerWillChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controller(_ control: NSFetchedResultsController<NSFetchRequestResult>,
    didChange sectionInfo: NSFetchedResultsSectionInfo,
    atSectionIndex sectionIndex: Int, 
	for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex),
        with: .fade)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex),
        with: .fade)
    case .move: break
    case .update: break
    }
  }

  func controller(_ control: NSFetchedResultsController<NSFetchRequestResult>,
    didChange anObject: Any, at indexPath: IndexPath?,
    for type: NSFetchedResultsChangeType,
    newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let nip = newIndexPath else { fatalError("How?") }
      tableView.insertRows(at: [nip], with: .fade)
    case .delete:
      guard let ip = indexPath else { fatalError("How?") }
      tableView.deleteRows(at: [ip], with: .fade)
    case .move:
      guard let nip = newIndexPath else { fatalError("How?") }
      guard let ip = indexPath else { fatalError("How?") }
      tableView.deleteRows(at: [ip], with: .fade)
      tableView.insertRows(at: [nip], with: .fade)
    case .update:
      guard let ip = indexPath else { fatalError("How?") }
      tableView.reloadRows(at: [ip], with: .fade)
    }
  }

  func controller(_ control: NSFetchedResultsController<NSFetchRequestResult>,
    sectionIndexTitleForSectionName sectionName: String) -> String? {
    return "[\(sectionName)]"
  }

  func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
