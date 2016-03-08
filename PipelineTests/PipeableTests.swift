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
  func testPipeableIsPipedWithDefaultOutput() {
    let custom = CustomType()
    let pipe = Pipe(pipeable: custom, process: {return $0})
    
    var output: String?
    pipe.connect(Drain { output = $0 })
    custom.defaultPipe.insert(1)
    
    XCTAssertEqual(output, "1")
  }
}

extension PipeableTests {
  private struct CustomType: Pipeable {
    typealias DefaultPipeInput = Int
    typealias DefaultPipeOutput = String
    
    let defaultPipe = Pipe<DefaultPipeInput, DefaultPipeOutput> { return "\($0)" }
    
    func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput> {
      return defaultPipe
    }
    
    let intPipe = Pipe<Int, Int>()
    func pipe() -> Pipe<Int, Int> {
      return intPipe
    }
  }
}

