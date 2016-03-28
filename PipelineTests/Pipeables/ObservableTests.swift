//
//  ObservableTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class ObservableTests: XCTestCase {
  
  func testObservableCanConnectToInputable() {
    let observable = Observable(100)
    
    var callCount = 0
    var output: Int?
    observable.connect(Pipe {
      callCount += 1
      output = $0
    })
    
    observable.value = 123
    
    XCTAssertEqual(output, 123)
    XCTAssertEqual(callCount, 1)
  }
  
  func testObservableCanConnectUsingOperator() {
    let observable = Observable(100)
    
    var callCount = 0
    var output: Int?
    observable |- Pipe {
      callCount += 1
      output = $0
    }
    
    observable.value = 123
    
    XCTAssertEqual(output, 123)
    XCTAssertEqual(callCount, 1)
  }
  
  func testObservableDoesNotInsertValueIfItDidNotChange() {
    let observable = Observable(100)
    
    var callCount = 0
    observable |- Pipe { (Int) in
      callCount += 1
    }
    
    observable.value = 123
    XCTAssertEqual(callCount, 1)
    
    observable.value = 123
    XCTAssertEqual(callCount, 1)
  }
  
  func testInsertingValueInPipeUpdatesTheObservedValue() {
    let observable = Observable(100)
    let pipe = Pipe() |- observable
    pipe.insert(111)
    
    XCTAssertEqual(observable.value, 111)
  }
}

