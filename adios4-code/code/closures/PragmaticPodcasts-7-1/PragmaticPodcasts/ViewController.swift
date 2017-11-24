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
  
  var player : AVPlayer?
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var playPauseButton: UIButton!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var logoView: UIImageView!
  private var playerPeriodicObserver : Any?
  
  deinit {
    player?.removeObserver(self, forKeyPath: "rate")
    if let oldObserver = playerPeriodicObserver {
      player?.removeTimeObserver(oldObserver)
    }
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
  
  /*
   closure that just logs
   
  func set(url: URL) {
    if let oldObserver = playerPeriodicObserver {
      player?.removeTimeObserver(oldObserver)
    }
    player = AVPlayer(url: url)
    titleLabel.text = url.lastPathComponent
    player?.addObserver(self,
                        forKeyPath: "rate",
                        options: [],
                        context: nil)
    let interval = CMTime(seconds: 0.25, preferredTimescale: 1000) 
    playerPeriodicObserver = 
      player?.addPeriodicTimeObserver(forInterval: interval, 
                                      queue: nil, 
                                      using: 
        { currentTime in 
          print("current time \(currentTime.seconds)") 
      }) 
  }
   */

  /*
   Closure that calls updateTimeLabel(), but has a retain cycle
   
  func set(url: URL) {
    if let oldObserver = playerPeriodicObserver {
      player?.removeTimeObserver(oldObserver)
    }
    player = AVPlayer(url: url)
    titleLabel.text = url.lastPathComponent
    player?.addObserver(self,
                        forKeyPath: "rate",
                        options: [],
                        context: nil)
    let interval = CMTime(seconds: 0.25, preferredTimescale: 1000)
    playerPeriodicObserver =
      player?.addPeriodicTimeObserver(forInterval: interval,
                                      queue: nil)
      { currentTime in
        self.updateTimeLabel(currentTime)
    }
  }
   */

  
  /*
   final version - updates time, uses [weak self]
   */
  func set(url: URL) {
    if let oldObserver = playerPeriodicObserver {
      player?.removeTimeObserver(oldObserver)
    }
    player = AVPlayer(url: url)
    titleLabel.text = url.lastPathComponent
    player?.addObserver(self,
                        forKeyPath: "rate",
                        options: [],
                        context: nil)
    let interval = CMTime(seconds: 0.25, preferredTimescale: 1000)
    playerPeriodicObserver =
      player?.addPeriodicTimeObserver(forInterval: interval,
                                      queue: nil)
      { [weak self] currentTime in
        self?.updateTimeLabel(currentTime)
    }
  }

  private func updateTimeLabel(_ currentTime: CMTime) {
    let totalSeconds = currentTime.seconds
    let minutes = Int(totalSeconds / 60)
    let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60)) 
    let secondsString = seconds >= 10 ? "\(seconds)" : "0\(seconds)" 
    timeLabel.text = "\(minutes):\(secondsString)"
  }
  
  // MARK: - KVO
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if keyPath == "rate",
      let player = object as? AVPlayer {
      playPauseButton.setTitle(player.rate == 0 ? "Play" : "Pause",
                               for: .normal)
    }
  }
}
