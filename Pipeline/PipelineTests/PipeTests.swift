//
//  PipeTests.swift
//  PipeTests
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class PipeTests: XCTestCase {
  func testPipeWithSameInputAndOutputHasDefaultInitializer() {
    let value = 1000
    var output: Int?
    let pipe = Pipe({ return $0 } as (Int)->Int)
    pipe |- Pipe( { (input: Int)->Int in
      output = input
      return input
    })
    
    pipe.insert(value)
    
    XCTAssertEqual(output, value)
  }
  
  func testConnectedPipesReceiveInput() {
    var output: String?
    let pipe1 = Pipe { $0 + 1 }
    let pipe2 = Pipe { $0 + 2 }
    let pipe3 = Pipe { (input: Int) -> String in
      output = "test \(input)"
      return output!
    }
    pipe1.connect(pipe2)
    pipe2.connect(pipe3)
    
    pipe1.insert(1)

    XCTAssertEqual(output, "test 4")
  }
  
  func testFusedPipesReceiveInput() {
    var output: String?
    let pipe = Pipe { (input: Int)->Int in
      return input + 1
      }.fuse(Pipe { (input: Int)->Int in
        return input + 2
        }.fuse(Pipe { (input: Int)->String in
          output = "test \(input)"
          return output!
        }))

    pipe.insert(1)

    XCTAssertEqual(output, "test 4")
  }
  
  func testPipeConnectIsParrallellizable() {
    var output1 = "test"
    var output2 = "test"
    let pipe = Pipe{ (input: Int) in return input }
    pipe.connect(Pipe {
      output1 = "\(output1) \($0 + 2)"
    })
    pipe.connect(Pipe {
      output2 = "\(output2) \($0 + 3)"
    })
    
    pipe.insert(1)
    
    XCTAssertEqual(output1, "test 3")
    XCTAssertEqual(output2, "test 4")
  }
  
  func testPipeFuseIsParrallellizable() {
    var output1 = "test"
    var output2 = "test"
    let pipe = Pipe{ (input: Int) in return input }
    _ = pipe.fuse(Pipe { (input: Int) in
        output1 = "\(output1) \(input + 2)"
      })
    _ = pipe.fuse(Pipe { (input: Int) in
        output2 = "\(output2) \(input + 3)"
      })
    
    pipe.insert(1)
    
    XCTAssertEqual(output1, "test 3")
    XCTAssertEqual(output2, "test 4")
  }
  
  func testPipeCanTerminateWithAnEndPipe() {
    var output: String?
    let pipe = Pipe().fuse(Pipe { output = $0 })
    
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
    let pipeline = Pipe { $0 + 1 }
    pipeline |- { $0 + 2 } |- { output1 = $0 }
    pipeline |- { $0 + 3 } |- { output2 = $0 }
    
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
  
  func testClosureCanBePiped() {
    var output = 0
    let pipeline = { return $0 + 1 } |- Pipe { output = $0 + 2 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 4)
  }
  
  func testClosureCanBePipedToAnotherClosure() {
    var output = 0
    let pipeline = { $0 + 1 } |- { output = $0 + 2 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 4)
  }
  
  func testStrongAnyPipeRetainsPipe() {
    var output = 0
    let pipeline = Pipe { $0 + 1 } |- AnyPipe(Pipe { output = $0 }, weak: false)
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 2)
  }
  
  func testAnyPipeDefaultsToStrong() {
    var output = 0
    let pipeline = Pipe { $0 + 1 } |- AnyPipe(Pipe { output = $0 })
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 2)
  }
  
  func testWeakAnyPipeDoesNotRetainPipe() {
    var output = 0
    let pipeline = Pipe { $0 + 1 } |- AnyPipe(Pipe { output = $0 }, weak: true)
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 0)
  }
  
  func testWeakAnyPipeMaintainsConnectionBetweenTwoStronglyHeldPipes() {
    var output = 0
    let endPipe = Pipe { output = $0 }
    let pipeline = Pipe { $0 + 1 } |- AnyPipe(endPipe, weak: true)
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 2)
    XCTAssertNotNil(endPipe) // to make sure it doesn't release
  }
}
