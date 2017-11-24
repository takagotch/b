//
//  PragmaticPodcastsTests.swift
//  PragmaticPodcastsTests
//
//  Created by Chris Adamson on 7/25/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import XCTest
@testable import PragmaticPodcasts

class PragmaticPodcastsTests: XCTestCase {
  
  var playerVC : ViewController?
  
  override func setUp() {
    super.setUp()
    let storyboard = UIStoryboard(name: "Main", bundle: nil) 
    guard let playerVC = storyboard.instantiateViewController(withIdentifier: 
      "PlayerViewController") as? ViewController else { return } 
    playerVC.loadViewIfNeeded() 
    self.playerVC = playerVC 
  }

  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  /*
   func testExample() {
   // This is an example of a functional test case.
   // Use XCTAssert and related functions to verify your tests
   // produce the correct results.
   }
   
   func testPerformanceExample() {
   // This is an example of a performance test case.
   self.measure {
   // Put the code you want to measure the time of here.
   }
   }
   */
  
  func testPlayerTitleLabel_WhenURLSet_ShowsCorrectFilename() { 
    guard let playerVC = playerVC else { 
      XCTFail("Couldn't load player scene") 
      return
    } 
    XCTAssertEqual("CocoaConf001.m4a", playerVC.titleLabel.text)
  }
  
  func testPlayerPlayPauseButton_WhenPlaying_ShowsPause() {
    guard let playerVC = playerVC else {
      XCTFail("Couldn't load player scene")
      return
    }
    playerVC.handlePlayPauseTapped(self) 
    XCTAssertEqual("Pause", 
                   playerVC.playPauseButton.title(for: .normal)) 
  }
  
}
