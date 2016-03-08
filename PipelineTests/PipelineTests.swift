//
//  PipelineTests.swift
//  PipelineTests
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipeLineTests: XCTestCase {
  func testPipeWithSameInputAndOutputHasDefaultInitializer() {
    let value = 1000
    var output: Int?
    let pipe: Pipe<Int, Int> = Pipe()
    pipe.connect(Pipe<Int, Int>(process: {
      output = $0
      return $0
    }))
    
    pipe.insert(value)
    
    XCTAssertEqual(output, value)
  }
  
  func testPipeConnectIsChainableInSequence() {
    var output: String?
    let pipe = Pipe {
      return $0 + 1
      }.connect(Pipe<Int,Int> {
        return $0 + 2
        }.connect(Pipe<Int, String> {
          output = "test \($0)"
          return output!
          }))
    
    pipe.insert(1)
    
    XCTAssertEqual(output, "test 4")
  }
  
  func testPipeConnectIsParrallellizable() {
    var output = "test"
    let pipe = Pipe()
      .connect(Pipe<Int,String> {
        output = "\(output) \($0 + 2)"
        return output
        })
      .connect(Pipe<Int,String> {
        output = "\(output) \($0 + 3)"
        return output
        })
    
    pipe.insert(1)
    
    XCTAssertEqual(output, "test 3 4")
  }
  
  func testPipeCanTerminateWithADrain() {
    var output: String?
    let pipe = Pipe().connect(Drain { output = $0 })
    
    pipe.insert("test")
    
    XCTAssertEqual(output, "test")
  }
}
