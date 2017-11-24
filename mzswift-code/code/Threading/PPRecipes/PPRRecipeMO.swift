//
//  PPRRecipeMO.swift
//  PPRecipes
//
//  Created by Marcus S. Zarra on 12/7/15.
//  Copyright © 2015 The Pragmatic Programmer. All rights reserved.
//

import Foundation
import CoreData

class PPRRecipeMO: NSManagedObject {

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    func lastUsedString() -> String {
        if let date = self.value(forKey: "lastUsed") as? Date {
            return dateFormatter.string(from: date)
        } else {
            return "Never Used"
        }
    }
}
