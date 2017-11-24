//
//  PPRDetailViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRDetailViewController: UITableViewController {
  var recipeMO: PPRRecipeMO?

  @IBOutlet var detailView: PPRDetailView?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let recipe = recipeMO else {
      fatalError("Recipe unassigned")
    }
    detailView?.populateFromRecipe(recipe)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else {
      fatalError("Unidentified segue")
    }
    assert(identifier == "editRecipe", "Unexpected identifier: \(identifier)")

    guard let controller = segue.destination as? PPREditRecipeViewController else {
      fatalError("Unexpected view controller in segue")
    }

    controller.recipeMO = recipeMO
  }
}

class PPRDetailView: UIView {
  @IBOutlet var recipeNameLabel: UILabel?
  @IBOutlet var authorLabel: UILabel?
  @IBOutlet var typeLabel: UILabel?
  @IBOutlet var servesLabel: UILabel?
  @IBOutlet var lastServedLabel: UILabel?
  @IBOutlet var descriptionLabel: UILabel?

  func populateFromRecipe(_ recipeMO: PPRRecipeMO) {
    recipeNameLabel?.text = recipeMO.value(forKey: "name") as? String
    authorLabel?.text = recipeMO.value(forKeyPath: "author.name") as? String
    typeLabel?.text = recipeMO.value(forKey: "type") as? String

    if let value = recipeMO.value(forKey: "serves") as? NSNumber {
      servesLabel?.text = value.stringValue
    } else {
      servesLabel?.text = "Unknown"
    }

    lastServedLabel?.text = recipeMO.lastUsedString()
    descriptionLabel?.text = recipeMO.value(forKey: "desc") as? String
  }
}
