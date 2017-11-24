//: Playground - noun: a place where people can play

import UIKit

//: Playground - noun: a place where people can play

import UIKit

//
// arrays
//

var models = ["iPhone SE", "iPhone 6s", "iPhone 7"]
type(of:models)
models.insert("iPhone 7 Plus", at: 0)
let firstItem = models[0]
models.removeLast()
models

let iPhones = ["iPhone SE", "iPhone 6s", "iPhone 7", "iPhone 7 Plus"] 
let iPads = ["iPad Air 2", "iPad Pro", "iPad mini"] 
models = iPhones 
models.append(contentsOf: iPads) 
models.insert(contentsOf: ["iPod touch"], at: 4) 

//
// sets
//

var set = Set<String>() 
set.insert("iPhone 7") 
set.insert("iPhone 7")  
set 

var iPhoneSet : Set = ["iPhone 7"]
var iPadSet : Set = ["iPad Air 2", "iPad mini", "iPad Pro"]
iPhoneSet.intersection(iPadSet)

iPadSet.insert("iPhone 7 Plus")
iPhoneSet.insert("iPhone 7 Plus")
iPhoneSet.intersection(iPadSet)
iPhoneSet.union(iPadSet)

//
// dictionaries
//

let sizeInMm = [
    "iPhone 7": 138.1,
    "iPhone 7 Plus" : 158.1,
    "iPad Air 2" : 240.0,
    "iPad Pro" : 305.7]
type(of:sizeInMm)
sizeInMm["iPhone 7"]
sizeInMm["iPad mini"]

//TODO: should show off count, keys


