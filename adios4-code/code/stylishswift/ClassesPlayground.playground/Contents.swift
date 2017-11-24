//: Playground - noun: a place where people can play
import UIKit
import AVFoundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/* first version cited in book
 class IOSDevice {
	var name : String
	var screenHeight : Double
	var screenWidth : Double
 }
 */

/* first version with an initializer
class IOSDevice {
    var name : String
    var screenHeight : Double
    var screenWidth : Double
    
    init (name: String, screenHeight: Double, screenWidth: Double) { 
        self.name = name
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    } 
}
 */


class IOSDevice : CustomStringConvertible {
    var name : String
    var screenHeight : Double
    var screenWidth : Double
    
    private var audioPlayer : AVPlayer?
    
    init (name: String, screenHeight: Double, screenWidth: Double) {
        self.name = name
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }
    
    var description: String {
        return "\(name), \(screenHeight) x \(screenWidth)"
    }
    
    var screenArea : Double {
        get {
            return screenWidth * screenHeight
        }
    }
    
    // for tuple section
    var screenHeightAndWidth : (height: Double, width: Double) {
        get {
            return (screenHeight, screenWidth)
        }
    }
    
    func playAudioFrom(url: URL) -> Void {
        audioPlayer = AVPlayer(url: url)
        audioPlayer!.play()
    }
    
    func stopAudio() -> Void {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
        }
        audioPlayer = nil
    }
    
}

// calling the class:

let iPhone7 = IOSDevice(name: "iPhone 7",
                        screenHeight: 138.1, screenWidth: 67.0)

// call computed property
iPhone7.screenArea

/*
 // call method
if let url = URL(string: "http://www.npr.org/streams/aac/live1_aac.pls") {
    iPhone7.playAudioFrom(url: url)
}
 */


// tuples
iPhone7.screenHeightAndWidth
iPhone7.screenHeightAndWidth.height
iPhone7.screenHeightAndWidth.0

// iterate with tuple
let iPhone7Plus = IOSDevice(name: "iPhone 7 Plus",
                            screenHeight: 158.1, screenWidth: 77.8)
let iPhoneSE = IOSDevice (name: "iPhone SE",
                          screenHeight: 123.8, screenWidth: 58.6)
let iPhones = [iPhoneSE, iPhone7, iPhone7Plus]
for (index, phone) in iPhones.enumerated() {
    print ("\(index): \(phone)")
}

/* hypothetical - see how functions pass around references to their objects.
 compare later to how structs, enums, etc. pass copies of the data.
 
 func destroyIOSDevice (device: IOSDevice) {
 device.screenWidth = 0.0
 device.screenHeight = 0.0
 device.name = ""
 }
 
 destroyIOSDevice(iPhone7)
 iPhone7
 
 */

