//
//  ViewController.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 7/25/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  private var player : AVPlayer?
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var playPauseButton: UIButton!
  @IBOutlet var logoView: UIImageView!
  
  deinit {
    player?.removeObserver(self, forKeyPath: "rate")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let url = URL(string: "http://traffic.libsyn.com/cocoaconf/CocoaConf001.m4a") {
      set(url: url)
    }
  }
  
  @IBAction func handlePlayPauseTapped(_ sender: Any) {
    if let player = player {
      if player.rate == 0 {
        player.play()
      } else {
        player.pause()
      }
    }
  }

  /* initial version that just sets label
  func setURL(url: URL) {
    player = AVPlayer(url: url)
    titleLabel.text = url.lastPathComponent
  }
  */
  
  func set(url: URL) {
    player = AVPlayer(url: url)
    titleLabel.text = url.lastPathComponent
    player?.addObserver(self,
                        forKeyPath: "rate",
                        options: [],
                        context: nil)
  }
  
  // MARK: - KVO
  override func observeValue(forKeyPath keyPath: String?, 
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?)
  { 
    if keyPath == "rate", 
      let player = object as? AVPlayer { 
      playPauseButton.setTitle(player.rate == 0 ? "Play" : "Pause", 
        for: .normal) 
    }
  }
  
}

