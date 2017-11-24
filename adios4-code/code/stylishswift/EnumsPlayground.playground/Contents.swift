//: Playground - noun: a place where people can play

import UIKit

enum ScreenType {
    case none
    case retina (screenHeight: Double, screenWidth: Double)
}


struct IOSDevice {
    var name : String
    var screenType : ScreenType
}

/*
let iPhone7 = IOSDevice(name: "iPhone 7",
                        screenType: ScreenType.retina(
                            screenHeight: 138.1, screenWidth: 67.0)) 
let appleTV4thGen = IOSDevice(name: "Apple TV (4th Gen)",
                              screenType: ScreenType.none)
*/


let iPhone7 = IOSDevice(name: "iPhone 7",
                        screenType: ScreenType.retina(
                            screenHeight: 138.1, screenWidth: 67.0))
let appleTV4thGen = IOSDevice(name: "Apple TV (4th Gen)",
                              screenType: ScreenType.none)


/* variation of appleTV3rdGen initializer that omits "ScreenType"
let appleTV4thGen = IOSDevice(name: "Apple TV (4th Gen)",
                              screenType: .none)
 */

extension IOSDevice : CustomStringConvertible { 
    var description : String {
        var screenDescription: String 
        switch screenType { 
        case .none: 
            screenDescription = "No screen"
        case .retina (let screenHeight, let screenWidth): 
            screenDescription = "Retina screen " +
                "\(screenHeight) x \(screenWidth)" 
        }
        return "\(name): \(screenDescription)" 
    }
}

/* not sure if we'll use this?
extension IOSDevice : Equatable {
    
    // operator overloading!
    static func == (lhs: IOSDevice, rhs: IOSDevice) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        
        switch lhs.screenType {
        case .none:
            switch rhs.screenType {
            case .none:
                return true
            default:
                return false
            }
        case .retina(let lhsScreenHeight, let lhsScreenWidth):
            switch rhs.screenType {
            case .none:
                return false
            case .retina(let rhsScreenHeight, let rhsScreenWidth):
                return lhsScreenHeight == rhsScreenHeight &&
                    lhsScreenWidth == rhsScreenWidth
            }
        }
    }
}

// note: be sure to add that you can use "_" for associated values you don't care about

iPhone7 == iPhone7
appleTV4thGen == iPhone7
 */


// optionals demo
let optionalString : String? = "iPhone7"
switch optionalString {
case .none:
    print ("nil!")
case .some(let value):
    print ("some! \(value)")
}
