//: Playground - noun: a place where people can play

import UIKit

struct IOSDevice {
    var name : String
    var screenHeight : Double
    var screenWidth : Double
}

let iPhone7 = IOSDevice(name: "iPhone 7", screenHeight: 138.1,
                        screenWidth: 67.0)


// extensions
extension IOSDevice {
    var screenArea : Double {
        get {
            return screenWidth * screenHeight
        }
    }
}
iPhone7.screenArea

extension Int {
    func addOne() -> Int {
        return self + 1
    }
}

extension IOSDevice : CustomStringConvertible {
    var description: String {
        return "\(name), \(screenHeight) x \(screenWidth)"
    }
}
