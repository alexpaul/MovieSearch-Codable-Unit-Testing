# MovieSearch-Codable-Unit-Testing
Using URLSession and Codable to make requests to the iTunes Search API

## Model 

```swift 
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
```

## URLSession 

**URLSession.shared** - singleton instance of a URLSession  

For basic requests, the URLSession class provides a [shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared) singleton session object that gives you a reasonable default behavior for creating tasks. Use the shared session to fetch the contents of a URL to memory with just a few lines of code.

Unlike the other session types, you don’t create the shared session; you merely access it by using this property directly. As a result, you don’t provide a delegate or a configuration object.

**NB**: Caches request by default  

## Singleton

You use singletons to provide a globally accessible, shared instance of a class. You can create your own singletons as a way to provide a unified access point to a resource or service that’s shared across an app, like an audio channel to play sound effects or a network manager to make HTTP requests.

[Singleton](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Singleton.html)  
[Managing a Shared Resource Using a Singleton
](https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton)    

## Error Handling 

Using associative types on the APIError enum to capture the given error in the MovieSearchAPI class. 

```swift
enum APIError: Error {
  case decodingError(Error)
  case networkError(Error)
  case badURL(String)
}
```

## Network Layer 

```swift 
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
```

MovieSearchAPI is marked  ``` final ``` so its not able to be subclassed.   

## Escaping Closures 

A closure is said to escape a function when the closure is passed as an argument to the function, but is called after the function returns. When you declare a function that takes a closure as one of its parameters, you can write @escaping before the parameter’s type to indicate that the closure is allowed to escape.

One way that a closure can escape is by being stored in a variable that is defined outside the function. As an example, many functions that start an asynchronous operation take a closure argument as a completion handler. The function returns after it starts the operation, but the closure isn’t called until the operation is completed—the closure needs to escape, to be called later.

[Closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)   

## Unit Testing 

```swift 
  func testMovieSearch() {
    let exp = expectation(description: "response returned")
    MovieSearchAPI.search(keyword: "comedy") { (apiError, movies) in
      if let apiError = apiError {
        XCTFail("\(apiError)")
      } else if let movies = movies {
        XCTAssertGreaterThan(movies.count, 0, "should be greater than 0")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 3.0)
  }
  
  func testMovieSearchInfo() {
    let exp = expectation(description: "response returned")
    guard let keyword = "black panther".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      XCTFail("malformatted string")
      return
    }
    MovieSearchAPI.search(keyword: keyword) { (apiError, movies) in
      if let apiError = apiError {
        XCTFail("\(apiError)")
      } else if let movies = movies {
        XCTAssertEqual(movies.first?.artistName, "Ryan Coogler", "should be equal to Ryan Coogler")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 3.0)
  }
```

## Resources 

[URLSession](https://developer.apple.com/documentation/foundation/urlsession)   
[Testing Asynchronous Operations with Expectations](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations/testing_asynchronous_operations_with_expectations)  

