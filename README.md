# MovieSearch-Codable-Unit-Testing
Using URLSession and Codable to make requests to the iTunes Search API

## Model 

```swift 
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
```

## URLSession 

**URLSession.shared** - singleton instance of a URLSession  

For basic requests, the URLSession class provides a [shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared) singleton session object that gives you a reasonable default behavior for creating tasks. Use the shared session to fetch the contents of a URL to memory with just a few lines of code.

Unlike the other session types, you don’t create the shared session; you merely access it by using this property directly. As a result, you don’t provide a delegate or a configuration object.

## Network Layer 

```swift 
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
```

## Error Handling 

Using associative types on the APIError enum to capture the given error in the MovieSearchAPI class. 

```swift
enum APIError: Error {
  case decodingError(Error)
  case networkError(Error)
}
```

## Resources 

[URLSession](https://developer.apple.com/documentation/foundation/urlsession)

