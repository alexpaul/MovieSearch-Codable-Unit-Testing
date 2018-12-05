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
  case badURL(String)
}

final class MovieSearchAPI {
  // the network request is an asynchronous call
  // means the resutl is not immediately returned
  // so here we will need to use a callback in the form of an (escaping closure) to return the response is returned from the request
  static func search(keyword: String, completionHandler: @escaping (APIError?, [Movie]?) -> Void)  {
    let urlString = "https://itunes.apple.com/search?media=movie&term=\(keyword)&limit=100"
    guard let url = URL(string: urlString) else {
      completionHandler(.badURL("malformatted url"), nil)
      return
    }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        completionHandler(.networkError(error), nil) // called when response is returned
      } else if let data = data {
        do {
          let searchData = try JSONDecoder().decode(Movie.SearchData.self, from: data)
          completionHandler(nil, searchData.results) // called when response is returned
        } catch {
          completionHandler(.decodingError(error), nil)
        }
      }
    }.resume()
  }
}
