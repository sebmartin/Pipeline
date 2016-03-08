//
//  PipelineOperatorTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipelineOperatorTests: XCTestCase {
  func testPipelineOperatorOperatesInSeries() {
    var output1 = 0 as Int
    var output2 = 0 as Int
    var output3 = 0 as Int
    
    let p = Pipe<Int,Int> {
      output1 = $0 + 1
      return output1
    } |- Pipe {
      output2 = $0 + 2
      return output2
    } |- Pipe<Int,Int> {
      output3 = $0 + 3
      return $0
    }
    p.insert(Int(0))
    
    XCTAssertEqual(output1, 1)
    XCTAssertEqual(output2, 3)
    XCTAssertEqual(output3, 6)
  }
  
  func testPipelineOperatorCanConnectPipeToDrain() {
    var output = 0
    let p = Pipe() |- Drain {
      output = $0
    }
    
    p.insert(1)
    XCTAssertEqual(output, 1)
  }
}
