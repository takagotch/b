//: Playground - noun: a place where people can play

import UIKit

// note: in the book's text, we change the string in the URL(string:) initializer to garbage (like "foo") to get into the catch blocks
if let myURL = URL(string: "http://apple.com/") {
    do {
        let myData = try Data (contentsOf: myURL, options: []) 
        let myString = String(data: myData, encoding: .utf8) 
    } catch let nserror as NSError { 
        print ("NSError: \(nserror)")
    } catch { 
        print ("No idea what happened there: \(error)")
    }
}
