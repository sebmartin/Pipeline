//
//  PipeableTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipeableTests: XCTestCase {
  func testPipeableIsPipedWithDefaultOutputWhenConnectedToDrain() {
    let custom = IntToStringCustomType()
    let pipe = Pipe(pipeable: custom, process: {return $0})
    var output: String?
    pipe.connect(Drain { output = $0 })
    
    custom.defaultPipe.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableIsPipedWithDefaultOutputWhenConnectedToPipe() {
    let custom = IntToStringCustomType()
    let pipe = Pipe(pipeable: custom, process: {return $0})
    var output: String?
    pipe.connect(Pipe<String,Void> { output = $0 })
    
    custom.defaultPipe.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableUsesDefaultOutputWhenPipedToDrainUsingOperator() {
    let custom = IntToStringCustomType()
    var output: String?
    custom |- Drain {
      output = $0
    }
    
    custom.defaultPipe.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableUsesDefaultInputOutputWhenPipedToPipeUsingOperator() {
    let custom = IntToStringCustomType()
    var output: String?
    custom |- Pipe<String,Void> {
      output = $0
    }
    
    custom.defaultPipe.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeablesCanBeChainedWithPipeableUsingOperator() {
    let custom1 = IntToIntCustomType()
    let custom2 = IntToIntCustomType()
    var output: Int?
    custom1 |- custom2 |- Drain {
      output = $0
    }
    
    custom1.defaultPipe.insert(1)
    
    XCTAssertEqual(output, 3)
  }
}

extension PipeableTests {
  private struct IntToStringCustomType: Pipeable {
    typealias DefaultPipeInput = Int
    typealias DefaultPipeOutput = String
    
    let defaultPipe = Pipe<DefaultPipeInput, DefaultPipeOutput> { return "custom \($0)" }
    
    func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput> {
      return defaultPipe
    }
  }
  
  private struct IntToIntCustomType: Pipeable {
    typealias DefaultPipeInput = Int
    typealias DefaultPipeOutput = Int
    
    let defaultPipe = Pipe<DefaultPipeInput, DefaultPipeOutput> { return $0 + 1 }
    
    func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput> {
      return defaultPipe
    }
  }
  
  private struct CustomTypeWithMultipleTypeFormats {
    
  }
}

