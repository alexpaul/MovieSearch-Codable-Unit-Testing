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
    return cell
  }
}

extension MovieSearchController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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

