//
//  ViewController.swift
//  MovieSearch
//
//  Created by Alex Paul on 12/5/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import UIKit

class MovieSearchController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  private var movies = [Movie]() {
    didSet {
      //tableView.reloadData() - UITableView.reloadData() must be used from main thread only
      // UI updates coming from an asynchronous call must be done on the main thread only
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
  }
  
  private func showAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    alertController.addAction(okAction)
    present(alertController, animated: true , completion: nil)
  }
}

extension MovieSearchController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
    let movie = movies[indexPath.row]
    cell.textLabel?.text = movie.trackName
    if let description = movie.longDescription {
      cell.detailTextLabel?.text = description
    }
    
    
    // image processing is blocking the main thread
//    do {
//      let data = try Data(contentsOf: movie.artworkUrl100)
//      cell.imageView?.image = UIImage(data: data)
//    } catch {
//      print("retrieving image data error: \(error)")
//    }
    
    // using concurrency via GCD and DispatchQueue
    // note: we should now have a placeholder image and activity indicator which will lead to
    // creating a custom cell to be more flexible with where we locate the indicator
//    let queue = DispatchQueue(label: "imageProcessing")
//    queue.async {
//      do {
//        let data = try Data(contentsOf: movie.artworkUrl100)
//        // back to the main thread to update the UI
//        DispatchQueue.main.async {
//          cell.imageView?.image = UIImage(data: data)
//        }
//      } catch {
//        print("retrieving image data error: \(error)")
//      }
//    }
    
    // using quality of service classes
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let data = try Data(contentsOf: movie.artworkUrl100)
        DispatchQueue.main.async {
          cell.imageView?.image = UIImage(data: data)
        }
      } catch {
        print("retrieving image data error: \(error)")
      }
    }
    
    
    return cell
  }
}

extension MovieSearchController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
}

extension MovieSearchController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // clear cache
    URLCache.shared.removeAllCachedResponses()
    
    searchBar.resignFirstResponder()
    guard let _ = searchBar.text?.isEmpty,
      let searchText = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    else { return }
    MovieSearchAPI.search(keyword: searchText) { (apiError, movies) in
      if let apiError = apiError {
        switch apiError {
        case .badURL(let str):
          print("badURL \(str)")
        case .networkError(let error):
          self.showAlert(title: "Network Error", message: error.localizedDescription)
        case .decodingError(let error):
          print("decoding error: \(error)")
        }
      } else if let movies = movies {
        self.movies = movies
      }
    }
  }
}

