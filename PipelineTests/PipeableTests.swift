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
    let pipeline = custom |- Drain {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableUsesDefaultInputOutputWhenPipedToPipeUsingOperator() {
    let custom = IntToStringCustomType()
    var output: String?
    let pipeline = custom |- Pipe<String,Void> {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeablesCanBeChainedWithPipeableUsingOperator() {
    let custom1 = IntToIntCustomType()
    let custom2 = IntToIntCustomType()
    var output: Int?
    let pipeline = custom1 |- custom2 |- Drain {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testConsecutivePipeablesCanBeConnectedToFormPipelineUsingOperator() {
    let custom1 = IntToIntCustomType()
    let custom2 = IntToIntCustomType()
    
    var output: Int?
    let pipeline = Pipe<Int,Int>() |- custom1 |- custom2 |- Pipe<Int,Void> { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipesAndPipeablesCanBeMixedToFormPipelineUsingOperator() {
    let custom1 = IntToIntCustomType()
    let custom2 = IntToIntCustomType()
    
    var output: Int?
    let pipeline = Pipe<Int,Int>() |- custom1 |- Pipe() |- custom2 |- Pipe<Int,Void> { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipeableCanBeAtTheBeginningOfPipeline() {
    let custom = IntToStringCustomType()
    var output: String?
    let pipeline = custom |- Drain {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableCanBeAtTheEndOfPipeline() {
    let custom1 = IntToIntCustomType()
    let custom2 = CustomEndType()
    let pipeline = custom1 |- custom2
    
    pipeline.insert(1)
    
    XCTAssertEqual(custom2.lastInput, 2)
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
  
  private class CustomEndType: Pipeable {
    typealias DefaultPipeInput = Int
    typealias DefaultPipeOutput = Int
    
    var lastInput: DefaultPipeInput?
    func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput> {
      return Pipe {
        self.lastInput = $0
        return $0
      }
    }
  }
  
  private struct CustomTypeWithMultipleTypeFormats {
    
  }
}

