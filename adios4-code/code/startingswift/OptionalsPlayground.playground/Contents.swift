//: Playground - noun: a place where people can play

import UIKit

let sizeInMm = [
    "iPhone 7": 138.1,
    "iPhone 7 Plus" : 158.1,
    "iPad Air 2" : 240.0,
    "iPad Pro" : 305.7]

let size7 = sizeInMm["iPhone 7"]
type(of:size7)

let size8 = sizeInMm["iPhone 8"]
type(of:size8)

type(of:size7!)

/*
type(of: size8!)
*/

if let size = size7 {
    type(of:size)
}

if let size = size8 {
    type(of:size)
}

if let size7 = size7, let size8 = size8 {
    type(of:size7)
    type(of:size8)
}

if let size7 = size7, size7 > 100.0 {
    size7
}
