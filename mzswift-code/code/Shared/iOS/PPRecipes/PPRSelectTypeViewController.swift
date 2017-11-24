//
//  PPRSelectTypeViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSelectTypeViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var fResultsController: NSFetchedResultsController<NSManagedObject>?
    var managedObjectContext: NSManagedObjectContext?
    var typeChangedClosure: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Type")
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        guard let moc = managedObjectContext else {
            fatalError("MOC not assigned before use")
        }
        fResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fResultsController?.delegate = self

        do {
            try fResultsController?.performFetch()
        } catch {
            fatalError("Failed to perform fetch: \(error)")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

//MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fResultsController?.fetchedObjects?.count else {
            fatalError("Failed to retrieve objects from FRC")
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)

      guard let type = fResultsController?.object(at: indexPath) else {
            fatalError("Failed to retrieve referenced managed object")
        }

      cell.textLabel?.text = type.value(forKey: "name") as? String
        return cell
    }

//MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let type = fResultsController?.object(at: indexPath) else {
            fatalError("Failed to retrieve referenced managed object")
        }
      guard let name = type.value(forKey: "name") as? String else {
            fatalError("Failed to retrieve name from managed object")
        }
        typeChangedClosure?(name)

        navigationController!.popViewController(animated: true)
    }
}
