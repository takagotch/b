//
//  ViewController.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 7/25/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import UIKit
import AVFoundation
// TODO: remember to include app transport security section

class ViewController: UIViewController {
  
  private var player : AVPlayer?
  
  override func viewDidLoad() { 
    super.viewDidLoad() 
    if let url = URL( 
      string: "http://traffic.libsyn.com/cocoaconf/CocoaConf001.m4a") { 
      set(url: url) 
    }
  }
  
  /*
   @IBAction func handlePlayPauseTapped(_ sender: Any) {
   }
   */
  
  /*
   @IBAction func handlePlayPauseTapped(_ sender: Any) {
     print("handlePlayPauseTapped")
   }
   */

  @IBAction func handlePlayPauseTapped(_ sender: Any) {
    player?.play()
  }
  
  func set(url: URL) {
    player = AVPlayer(url: url)
  }
  
}
