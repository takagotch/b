//
//  PodcastFeedParser.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 9/17/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import Foundation

class PodcastFeedParser : NSObject, XMLParserDelegate {

  var currentFeed : PodcastFeed?
  var currentElementText: String?
  
  init(contentsOf url: URL) {
    super.init() 
    let urlSession = URLSession(configuration: .default)
    let dataTask = urlSession.dataTask(with: url) {dataMb, responseMb, errorMb in
      if let data = dataMb {
        let parser = XMLParser(data: data) 
        parser.delegate = self 
        parser.parse() 
      }
    }
    dataTask.resume()
  }

/* early example in book text that just logs when parsing begins
  func parserDidStartDocument(_ parser: XMLParser) {
    print ("parserDidStartDocument, " +
    "currently on line \(parser.lineNumber)")
  }
*/
  
// MARK: - XMLParserDelegate implementation
  
  func parserDidStartDocument(_ parser: XMLParser) {
    currentFeed = PodcastFeed()
  }
  
/* early version quoted in the book
  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?,
              attributes attributeDict: [String : String] = [:]) {
    switch elementName {
    case "title", "link", "description", "itunes:author":
      currentElementText = ""
    case "itunes:image":
      if let urlAttribute = attributeDict["href"] {
        currentFeed?.iTunesImageURL = URL(string: urlAttribute)
    }
    default:
      currentElementText = nil
    }
  }
*/
  
  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?,
              attributes attributeDict: [String : String] = [:]) {
    switch elementName {
    case "title", "link", "description",
         "itunes:image", "itunes:author":
      currentElementText = ""
    case "item":
      parser.abortParsing()
      print("aborted parsing. podcastFeed = \(currentFeed)")
    default:
      currentElementText = nil
    }
    if elementName == "item" {
      parser.abortParsing()
      print("aborted parsing. podcastFeed = \(currentFeed)")
    }
  }
 
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    currentElementText?.append(string)
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case "title":
      currentFeed?.title = currentElementText
    case "link":
      if let linkText = currentElementText {
        currentFeed?.link = URL(string: linkText)
      }
    case "description":
      currentFeed?.description = currentElementText
    case "itunes:author":
      currentFeed?.iTunesAuthor = currentElementText
    default:
      break
    }
  }
  
}
