//
//  Movie.swift
//  MovieSearch
//
//  Created by Alex Paul on 12/5/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import Foundation

struct Movie: Codable {
  let collectionId: Int?
  let trackId: Int
  let artistName: String
  let collectionName: String?
  let trackName: String
  let artworkUrl100: URL
  let longDescription: String?
  
  struct SearchData: Codable {
    let resultCount: Int
    let results: [Movie]
  }
  // optionals are marked as needed as some movies are missing those properties
}
