//
//  PodcastFeedParser.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 9/17/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import Foundation

/* empty stub used in the book, just to get us started
 class PodcastFeedParser {
 
 }
 */


class PodcastFeedParser {

/*
  init(contentsOf url: URL) {
    let urlSession = URLSession(configuration: .default)
    let dataTask = urlSession.dataTask(with: url) {dataMb, responseMb, errorMb in
      if let data = dataMb {
        print ("PodcastFeedParser got data: \(data)")
      }
    }
    dataTask.resume()
  }
*/
  
   // finished version in book
  init(contentsOf url: URL) {
    let urlSession = URLSession(configuration: .default)
    let dataTask = urlSession.dataTask(with: url) {dataMb, responseMb, errorMb in
      if let data = dataMb {
        if let dataString = String(data: data, encoding: .utf8) {
          print ("podcast feed contents: \(dataString)")
        }
      }
    }
    dataTask.resume()
  }
  
}
