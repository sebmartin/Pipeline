//
//  PipeableTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class PipeableTests: XCTestCase {
  
  func testPipeableIsPipedWithDefaultOutputWhenFusedToPipe() {
    let custom = IntToStringPipeable()

    var output: String?
    let pipeline = Pipe().fuse(custom.fuse(Pipe { output = $0 }))
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableUsesDefaultInputOutputWhenPipedToPipeUsingOperator() {
    let custom = IntToStringPipeable()
    var output = ""
    let pipeline = custom |- Pipe { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeablesCanBeChainedWithPipeableUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    var output = 0
    let pipeline = custom1 |- custom2 |- Pipe() |- Pipe {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testConsecutivePipeablesCanBeConnectedToFormPipelineUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    
    var output = 0
    let pipeline = Pipe() |- custom1 |- custom2 |- Pipe { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipesAndPipeablesCanBeMixedToFormPipelineUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    
    var output = 0
    let pipeline = Pipe() |- custom1 |- Pipe() |- custom2 |- Pipe { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipeableCanBeAtTheBeginningOfPipeline() {
    let custom = IntToStringPipeable()
    var output = ""
    let pipeline = custom |- Pipe { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableCanBeAtTheEndOfPipeline() {
    var output = 0
    let custom1 = IntToIntPipeable()
    let custom2 = CustomEndType { output = $0 }
    let pipeline = custom1 |- custom2
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 2)
  }
}

// MARK: - Custom Pipeables

fileprivate extension PipeableTests {
  class IntToStringPipeable: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = String

    var pipe = AnyPipe(Pipe({ (input: Int) in return "custom \(input)" }))
  }
  
  class IntToIntPipeable: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = Int
    
    var pipe = AnyPipe(Pipe({ return $0 + 1 }))
  }
  
  class CustomEndType: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = Void
    
    let processor: (PipeInput) -> PipeOutput?
    var pipe: AnyPipe<PipeInput, Void>
    init(_ processor: @escaping (PipeInput) -> PipeOutput) {
      self.processor = processor
      self.pipe = AnyPipe(Pipe(processor))
    }
  }
}
