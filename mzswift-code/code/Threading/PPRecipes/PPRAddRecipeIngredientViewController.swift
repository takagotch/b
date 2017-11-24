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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let ingredientType = recipeIngredientMO.value(forKey: "ingredient") as? NSManagedObject else {
            return
        }

        let path = IndexPath(row: 1, section: 0)
        guard let cell = tableView.cellForRow(at: path) else {
            return
        }
        cell.textLabel?.text = ingredientType.value(forKeyPath: "unitOfMeasure.name") as? String
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { fatalError("Segue without an identifier") }
        let destination = segue.destination

        switch destination {
        case let controller as PPRTextEditViewController:
            let quantity = recipeIngredientMO.value(forKey: "quantity") as! NSNumber
            controller.text = quantity.stringValue
            controller.textChangedClosure = {
                (newText: String) in
                let numberFormatter = NumberFormatter()
                guard let quantity = numberFormatter.number(from: newText) else {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid quantity"]
                    throw NSError(domain: "PragProg", code: 1123, userInfo: userInfo)
                }

                let path = IndexPath(row: 0, section: 0)
                let cell = self.tableView.cellForRow(at: path)
                cell?.detailTextLabel?.text = newText
                self.recipeIngredientMO.setValue(quantity, forKey: "quantity")
            }
        case let controller as PPRSelectIngredientTypeViewController:
            controller.managedObjectContext = recipeIngredientMO.managedObjectContext
            controller.selectIngredientType = {
                (ingredientType: NSManagedObject) in
                self.recipeIngredientMO.setValue(ingredientType, forKey: "ingredient")

                var path = IndexPath(row: 1, section: 0)
                var cell = self.tableView.cellForRow(at: path)
                cell?.detailTextLabel?.text = ingredientType.value(forKey: "name") as? String

                path = IndexPath(row: 0, section: 0)
                cell = self.tableView.cellForRow(at: path)
                cell?.textLabel?.text = ingredientType.value(forKeyPath: "unitOfMeasure.name") as? String
            }
        default:
            print("Unknown identifier: \(identifier)")
        }
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
