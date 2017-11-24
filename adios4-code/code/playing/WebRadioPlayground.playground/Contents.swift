//: Playground - noun: a place where people can play

import UIKit

import AVFoundation 
let url = URL(string: 
    "http://www.npr.org/streams/aac/live1_aac.pls") 
let player = AVPlayer(url: url!) 
player.play() 

import PlaygroundSupport 
PlaygroundPage.current.needsIndefiniteExecution = true 
