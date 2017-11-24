//
//  PPRSetDateViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PPRSetDateViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker?
    var dateChangedClosure: ((_ newDate: Date) -> Void)?

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

    @IBAction func done(_ sender: AnyObject) {
        guard let date = datePicker?.date else {
            fatalError("unable to retrieve date")
        }
        dateChangedClosure?(date)
        navigationController!.popViewController(animated: true)
    }
}
