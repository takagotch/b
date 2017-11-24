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
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self
        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Unidentified segue")
        }

        switch identifier {
        case "showRecipe":
            guard let controller = segue.destination as? PPRDetailViewController else {
                fatalError("Unexpected view controller in segue")
            }
            if let path = tableView.indexPathForSelectedRow {
                controller.recipeMO = fResultsController?.object(at: path) as? PPRRecipeMO
            }
        case "addRecipe":
            guard let controller = segue.destination as? PPREditRecipeViewController else {
                fatalError("Unexpected view controller in segue")
            }
            guard let moc = managedObjectContext else {
                fatalError("Context not set")
            }
            guard let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: moc) as? PPRRecipeMO else {
                fatalError("Failed to create new entity, is entity class not set in the model?")
            }
            controller.recipeMO = recipe
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fResultsController?.sections?[section] else {
            fatalError("Failed to resolve FRC")
        }
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        let object = fResultsController?.object(at: indexPath)
        cell.textLabel?.text = object?.value(forKey: "name") as? String
        return cell
    }

//MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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
