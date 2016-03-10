//
//  ObservableTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class ObservableTests: XCTestCase {
  func testObservableCanConnectToInputable() {
    var observable = Observable(100)
    
    var callCount = 0
    var output: Int?
    observable.connect(Drain {
      callCount += 1
      output = $0
    })
    
    observable.value = 123
    
    XCTAssertEqual(output, 123)
    XCTAssertEqual(callCount, 1)
  }
  
  func testObservableCanConnectUsingOperator() {
    var observable = Observable(100)
    
    var callCount = 0
    var output: Int?
    observable |- Drain {
      callCount += 1
      output = $0
    }
    
    observable.value = 123
    
    XCTAssertEqual(output, 123)
    XCTAssertEqual(callCount, 1)
  }
}

