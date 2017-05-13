//
//  PipelineOperatorTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipeableOperatorTests: XCTestCase {
  func testPipeableOperatorOperatesInSeries() {
    var output1 = 0 as Int
    var output2 = 0 as Int
    var output3 = 0 as Int
    
    let p = Pipe { (input: Int)->Int in
      output1 = input + 1
      return output1
    } |- Pipe { (input: Int)->Int in
      output2 = input + 2
      return output2
    } |- Pipe { (input: Int)->Int in
      output3 = input + 3
      return output3
    }
    p.insert(Int(0))
    
    XCTAssertEqual(output1, 1)
    XCTAssertEqual(output2, 3)
    XCTAssertEqual(output3, 6)
  }
  
  func testPipeableOperatorCanConnectPipeToAnEndPipeWithNoReturn() {
    var output = 0
    let p = Pipe() |- Pipe {
      output = $0
    }
    
    p.insert(1)
    XCTAssertEqual(output, 1)
  }
}
