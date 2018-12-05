//
//  Movie.swift
//  MovieSearch
//
//  Created by Alex Paul on 12/5/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import Foundation

struct Movie: Codable {
  let collectionId: Int? // needs to be an optional
  let trackId: Int
  let artistName: String
  let collectionName: String? // needs to be an optional
  let trackName: String
  let artworkUrl100: URL
  let longDescription: String
  struct SearchData: Codable {
    let resultCount: Int
    let results: [Movie]
  }
}
