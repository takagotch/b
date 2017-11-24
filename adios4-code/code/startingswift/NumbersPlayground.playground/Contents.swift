//: Playground - noun: a place where people can play

import UIKit

//: Playground - noun: a place where people can play

import UIKit

// difference between let and var
/*
 let foo = 1
 foo += 1
 */


// types - Int, Float, Double


var bar : Double = 0
type(of: bar)

var zero = 0
type(of: zero)

let pointFive = 0.5
type(of: pointFive)

let myFloat : Float = 0.5
type(of: myFloat)

let myOtherFloat = Float (0.5)
type(of: myOtherFloat)

// won't work - can't convert float to int
/*
 let floatToInt : Int = myFloat
 let floatToDouble : Double = myFloat
 */

/*
 let myInt = 1
 let myDouble : Double = myInt
 */

let myInt = 1
let myDouble = Double(myInt)

let floatToInt = Int (myFloat)
type(of: floatToInt)

let rounded = round(myFloat)
let roundedUp = ceil(myFloat)
let roundedDown = floor(myFloat)

// tuples? save for next chapter?
type(of: (2, 2.5))
