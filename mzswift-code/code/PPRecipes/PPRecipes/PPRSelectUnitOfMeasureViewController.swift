//
//  PPRSelectUnitOfMeasureViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectUnitOfMeasureViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var managedObjectContext: NSManagedObjectContext?
  var selectUnitOfMeasure: ((_ unitOfMeasure: NSManagedObject) -> Void)?
  var fResultsController: NSFetchedResultsController<NSManagedObject>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let fetch = NSFetchRequest<NSManagedObject>(entityName: "UnitOfMeasure")
    fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    guard let moc = self.managedObjectContext else {
      fatalError("No MOC assigned")
    }
    fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    fResultsController?.delegate = self
    
    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Failed to performFetch: \(error)")
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified Segue")
    }
    if identifier != "addUnitOfMeasure" {
      fatalError("Unknown Segue: \(identifier)")
    }
    let controller = segue.destination as! PPRTextEditViewController
    
    controller.textChangedClosure = { (text: String) in
      if text.characters.count == 0 {
        throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Invalid Name"])
      }
      guard let moc = self.managedObjectContext else {
        fatalError("No MOC assigned")
      }
      let fetch = NSFetchRequest<NSManagedObject>(entityName: "UnitOfMeasure")
      fetch.predicate = NSPredicate(format: "name == %@", text)
      do {
        let count = try moc.count(for: fetch)
        if count > 0 {
          throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey: "Already Exists"])
        }
      } catch {
        fatalError("Error fetching: \(error)")
      }
      let uom = NSEntityDescription.insertNewObject(forEntityName: "UnitOfMeasure", into: moc)
      uom.setValue(text, forKey: "name")
      
      self.dismiss(animated: true) {}
    }
    
  }
  
  //MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sectionInfo = fResultsController?.sections?[section] {
      return sectionInfo.numberOfObjects
    }
    return 0
  }
  
  //MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let uom = fResultsController?.object(at: indexPath) else { return }
    selectUnitOfMeasure?(uom)
    navigationController!.popViewController(animated: true)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
    let uom = fResultsController?.object(at: indexPath)
    cell.textLabel?.text = uom?.value(forKey: "name") as? String
    
    return cell
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
