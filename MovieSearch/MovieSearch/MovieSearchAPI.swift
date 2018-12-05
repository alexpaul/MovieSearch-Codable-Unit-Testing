//
//  MovieSearchAPI.swift
//  MovieSearch
//
//  Created by Alex Paul on 12/5/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import Foundation

enum APIError: Error {
  case decodingError(Error)
  case networkError(Error)
}

final class MovieSearchAPI {
  
  // the network request is an asynchronous call
  // means the resutl is not immediately returned
  // so here we will need to use a callback in the form of an (escaping closure) to return the response is returned from the request
  static func search(completionHandler: @escaping (APIError?, [Movie]?) -> Void)  {
    let urlString = "https://itunes.apple.com/search?media=movie&term=holiday&limit=100"
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!) { (data, response, error) in
      if let error = error {
        completionHandler(.networkError(error), nil) // called when response is returned
      } else if let data = data {
        do {
          let searchData = try JSONDecoder().decode(Movie.SearchData.self, from: data)
          completionHandler(nil, searchData.results) // called when response is returned
        } catch {
          print("decoding error: \(error)")
          completionHandler(.decodingError(error), nil)
        }
      }
    }.resume()
  }
  
}
