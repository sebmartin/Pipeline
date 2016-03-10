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
  
  func testPipeableIsPipedWithDefaultOutputWhenConnectedToPipe() {
    let custom = IntToStringPipeable()

    var output: String?
    let pipeline = Pipe().connect(custom.connect(Pipe { output = $0 }))
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableUsesDefaultInputOutputWhenPipedToPipeUsingOperator() {
    let custom = IntToStringPipeable()
    var output: String?
    let pipeline = custom |- Pipe { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeablesCanBeChainedWithPipeableUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    var output: Int?
    let pipeline = custom1 |- custom2 |- Pipe {
      output = $0
    }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testConsecutivePipeablesCanBeConnectedToFormPipelineUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    
    var output: Int?
    let pipeline = Pipe() |- custom1 |- custom2 |- Pipe { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipesAndPipeablesCanBeMixedToFormPipelineUsingOperator() {
    let custom1 = IntToIntPipeable()
    let custom2 = IntToIntPipeable()
    
    var output: Int?
    let pipeline = Pipe() |- custom1 |- Pipe() |- custom2 |- Pipe { output = $0 }
    pipeline.insert(1)
    
    XCTAssertEqual(output, 3)
  }
  
  func testPipeableCanBeAtTheBeginningOfPipeline() {
    let custom = IntToStringPipeable()
    var output: String?
    let pipeline = custom |- Pipe { output = $0 }
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, "custom 1")
  }
  
  func testPipeableCanBeAtTheEndOfPipeline() {
    var output = nil as Int?
    let custom1 = IntToIntPipeable()
    let custom2 = CustomEndType { output = $0 }
    let pipeline = custom1 |- custom2
    
    pipeline.insert(1)
    
    XCTAssertEqual(output, 2)
  }
}

// MARK: - Custom Pipeables

extension PipeableTests {
  private struct IntToStringPipeable: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = String

    let pipe = Pipe<PipeInput, PipeOutput> { return "custom \($0)" }
  }
  
  private struct IntToIntPipeable: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = Int
    
    let pipe = Pipe<PipeInput, PipeOutput> { return $0 + 1 }
  }
  
  private struct CustomEndType: Pipeable {
    typealias PipeInput = Int
    typealias PipeOutput = Void
    
    let processor: ((PipeInput) -> PipeOutput)?
    let pipe: Pipe<PipeInput, Void>
    init(_ processor: (PipeInput) -> PipeOutput) {
      self.processor = processor
      self.pipe = Pipe(processor: processor)
    }
  }
}
