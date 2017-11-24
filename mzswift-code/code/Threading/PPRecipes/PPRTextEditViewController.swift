//
//  PPRTextEditViewController.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/6/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import UIKit

class PPRTextEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField?
    @IBOutlet var textView: UITextView?
    var textChangedClosure: ((String) throws -> Void)?
    var text: String? {
        get {
            if let field = textField {
                return field.text
            } else if let view = textView {
                return view.text
            } else {
                return nil
            }
        }
        set(newText) {
            if let field = textField {
                field.text = newText
            } else if let view = textView {
                view.text = newText
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func handleTextCompletion() -> Bool {
        guard let inputtedText = self.text else {
            let alert = UIAlertController(title: "Error", message: "Text cannot be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return false
        }
        do {
            try textChangedClosure?(inputtedText)
            return true
        } catch let error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return false
        }
    }

    @IBAction func done(_ sender: AnyObject) {
        _ = handleTextCompletion()
        navigationController!.popViewController(animated: true)
    }

    @IBAction func cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

//MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return handleTextCompletion()
    }
}
