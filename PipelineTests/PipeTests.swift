//
//  PipeTests.swift
//  PipeTests
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipeTests: XCTestCase {
  func testPipeWithSameInputAndOutputHasDefaultInitializer() {
    let value = 1000
    var output: Int?
    let pipe = Pipe<Int,Int>()
    pipe.connect(Pipe<Int,Int> {
      output = $0
      return $0
    })
    
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
  
  func testPipeCanTerminateWithAnEndPipe() {
    var output: String?
    let pipe = Pipe().connect(Pipe { output = $0 })
    
    pipe.insert("test")
    
    XCTAssertEqual(output, "test")
  }
  
  func testPipesCanUseOperator() {
    var output: String?
    let pipeline = Pipe() |- { output = $0 }
    
    pipeline.insert("test")
    
    XCTAssertEqual(output, "test")
  }
  
  func testConsecutivePipesCanBeConnectedToFormPipeline() {
    var output = 0
    let pipeline = { return $0 + 1 } |- { return $0 + 2 } |- { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 4)
  }
  
  func testPipesCanSplitToParrallelPipesUsingOperator() {
    // 1 -> Pipe(+1) -> Pipe(+2) -> 4
    //            \---> Pipe(+3) -> 5
    var output1 = 0, output2 = 0
    let pipeline = Pipe { return $0 + 1 }
    pipeline |- { return $0 + 2 } |- { output1 = $0 }
    pipeline |- { return $0 + 3 } |- { output2 = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output1, 4)
    XCTAssertEqual(output2, 5)
  }
  
  func testPipesCanBeConnectedUsingTheInitializer() {
    var output = 0
    let pipeline = Pipe { return $0 + 1 } |- Pipe { return $0 + 2 } |- Pipe { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 4)
  }
}
