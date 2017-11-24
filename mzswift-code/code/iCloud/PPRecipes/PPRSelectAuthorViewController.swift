//
//  PPRSelectAuthorViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectAuthorViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var managedObjectContext: NSManagedObjectContext?
  var fResultsController: NSFetchedResultsController<NSManagedObject>?
  var selectAuthorClosure: ((NSManagedObject) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = editButtonItem
    
    guard let moc = managedObjectContext else {
      fatalError("Context not assigned")
    }
    
    let fetch = NSFetchRequest<NSManagedObject>(entityName: "Author")
    fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    fResultsController?.delegate = self
    
    do {
      try fResultsController?.performFetch()
    } catch {
      fatalError("Error performing fetch: \(error)")
    }
  }
  
  @IBAction func cancel(_ sender: AnyObject) {
    navigationController!.popViewController(animated: true)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to access FRC")
    }
    let path = IndexPath(row: count, section: 0)
    
    if editing {
      tableView.deleteRows(at: [path], with: .fade)
    } else {
      tableView.insertRows(at: [path], with: .fade)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let controller = segue.destination as? PPRTextEditViewController else {
      fatalError("Unexpected controller in segue")
    }
    
    controller.textChangedClosure = { (text: String) in
      let fetch = NSFetchRequest<NSManagedObject>(entityName: "Author")
      fetch.predicate = NSPredicate(format: "name == %@", text)
      
      guard let moc = self.managedObjectContext else {
        fatalError("MOC not assigned")
      }
      
      do {
        let count = try moc.count(for: fetch)
        if count > 0 {
          throw NSError(domain: "PragProg", code: 1123, userInfo: [NSLocalizedDescriptionKey:"Author already exists"])
        }
      } catch {
        fatalError("Failed to perform fetch: \(error)")
      }
      
      
      let newAuthor = NSEntityDescription.insertNewObject(forEntityName: "Author", into: moc)
      newAuthor.setValue(text, forKey: "name")
    }
  }
  
  //MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to realize FRC")
    }
    if isEditing {
      return count + 1
    } else {
      return count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to realize FRC")
    }
    if indexPath.row >= count {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kInsertCellIdentifier) else {
        fatalError("Failed to retrieve cell for identifier: \(kInsertCellIdentifier)")
      }
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
    
    let author = fResultsController?.object(at: indexPath)
    cell.textLabel?.text = author?.value(forKey: "name") as? String
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .insert {
      performSegue(withIdentifier: "addAuthor", sender: self)
      return
    }
    
    guard let mo = fResultsController?.object(at: indexPath), let moc = managedObjectContext else {
      fatalError("Failed to realize MO or MOC")
    }
    
    moc.delete(mo)
  }
  
  //MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to realize FRC")
    }
    if indexPath.row >= count {
      return true
    }
    
    let author = fResultsController?.object(at: indexPath)
    
    if let recipes = author?.value(forKey: "recipes") as? [NSManagedObject] {
      return recipes.count == 0
    } else {
      return true
    }
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to realize FRC")
    }
    
    if indexPath.row >= count {
      return .insert
    }
    
    let author = fResultsController?.object(at: indexPath)
    
    guard let recipes = author?.value(forKey: "recipes") as? [NSManagedObject] else {
      return .delete
    }
    if recipes.count > 0 {
      return .none
    }
    return .delete
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let count = fResultsController?.fetchedObjects?.count else {
      fatalError("Failed to realize FRC")
    }
    if indexPath.row >= count {
      return
    }
    
    guard let author = fResultsController?.object(at: indexPath) else {
      fatalError("Failed to realize FRC")
    }
    
    selectAuthorClosure?(author)
    
    navigationController!.popViewController(animated: true)
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
