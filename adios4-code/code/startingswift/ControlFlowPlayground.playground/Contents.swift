//: Playground - noun: a place where people can play

import UIKit

// for-in loop
let models = ["iPhone 7", "iPhone 7 Plus", "iPad Air 2", 
    "iPad mini", "iPad Pro"] 
for model in models { 
    print ("model: \(model)") 
}

// for loop with index
for i in 0 ..< models.count {
    print ("model at index \(i): \(models[i])")
}

// for loop with both index and item will be introduced next chapter

// if
let sizeInMm = [
    "iPhone 7": 138.1,
    "iPhone 7 Plus" : 158.1,
    "iPad Air 2" : 240.0,
    "iPad Pro" : 305.7]

let model = "iPhone 7"
if sizeInMm[model] != nil {
    print ("size of \(model) is \(sizeInMm[model])") 
} else {
    print ("couldn't find \(model)") 
}

// guard doesn't really work in a playground

// switch
switch model {
case "iPhone 7 Plus":
    print ("That's what I want")
case "iPhone 8":
    print ("Maybe next year?")
default:
    print ("Not my thing")
}
