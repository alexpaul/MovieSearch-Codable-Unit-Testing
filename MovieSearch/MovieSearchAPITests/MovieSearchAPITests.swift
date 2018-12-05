//
//  MovieSearchAPITests.swift
//  MovieSearchAPITests
//
//  Created by Alex Paul on 12/5/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import XCTest
@testable import MovieSearch

class MovieSearchAPITests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testMovieSearch() {
    let exp = expectation(description: "response returned")
    
    MovieSearchAPI.search { (apiError, movies) in
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
    
    MovieSearchAPI.search { (apiError, movies) in
      if let apiError = apiError {
        XCTFail("\(apiError)")
      } else if let movies = movies {
        XCTAssertEqual(movies.first?.artistName, "Nancy Meyers", "should be equal to Nancy Meyers")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 3.0)
    
  }
  
}
