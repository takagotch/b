//
//  EpisodeListViewController.swift
//  PragmaticPodcasts
//
//  Created by Chris Adamson on 10/4/16.
//  Copyright © 2016 Pragmatic Programmers, LLC. All rights reserved.
//

import UIKit

class EpisodeListViewController: UIViewController,
UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var table: UITableView!
  
  var feeds : [PodcastFeed] = [] {
    didSet {
      DispatchQueue.main.async {
        self.table.reloadData()
      }
    }
  }
  
  //MARK: - UITableViewDataSource

  func numberOfSections(in tableView: UITableView) -> Int {
    return feeds.count
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return feeds[section].episodes.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let episode = feeds[indexPath.section].episodes[indexPath.row] 
    let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", 
                                             for: indexPath) as! EpisodeCell 
    cell.titleLabel.text = episode.title 
    cell.durationLabel.text = episode.iTunesDuration 

    return cell
  }
  
  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int) -> String? {
    let feed = feeds[section]
    return feed.title
  }

}
