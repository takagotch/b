//
//  PodcastEpisodeParser.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 9/24/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import Foundation

/* stub copied over to the book
class PodcastEpisodeParser : NSObject, XMLParserDelegate {
  
}
 */

class PodcastEpisodeParser : NSObject, XMLParserDelegate {
  
  let feedParser : PodcastFeedParser
  var currentEpisode : PodcastEpisode
  var currentElementText: String?
  
  init(feedParser: PodcastFeedParser, xmlParser: XMLParser) {
    self.feedParser = feedParser
    self.currentEpisode = PodcastEpisode()
    super.init()
    xmlParser.delegate = self
  }
  
  //MARK: - URLParserDelegate
  
  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?,
              attributes attributeDict: [String : String] = [:]) {
    switch elementName {
    case "title", "itunes:duration":
      currentElementText = ""
    case "itunes:image":
      if let urlAttribute = attributeDict["href"] {
        currentEpisode.iTunesImageURL = URL(string: urlAttribute)
      }
      currentElementText = nil
    case "enclosure":
      if let href = attributeDict["url"], let url = URL(string:href) {
        currentEpisode.enclosureURL = url
      }
      currentElementText = nil
    default:
      currentElementText = nil
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    currentElementText?.append(string)
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case "title":
      currentEpisode.title = currentElementText
    case "itunes:duration":
      currentEpisode.iTunesDuration = currentElementText
    case "item":
      parser.delegate = feedParser 
      feedParser.parser(parser, didEndElement: elementName, 
                        namespaceURI: namespaceURI, qualifiedName: qName) 
    default:
      break
    }
  }
}
