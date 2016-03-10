//
//  PipeLineTests2.swift
//  Reading
//
//  Created by Seb Martin on 2016-03-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

// MARK: - Protocols

public protocol Inputable {
  typealias PipeInput

  func insert(input: PipeInput)
}

public protocol Outputable {
  typealias PipeOutput
  
  mutating func connect<I: Inputable where I.PipeInput == PipeOutput>(inputable: I) -> Self
}

public protocol Processable {
  typealias PipeInput
  typealias PipeOutput
  
  var processor: (PipeInput) -> PipeOutput { get set }
  init(processor: (PipeInput) -> PipeOutput)
}

extension Processable where PipeInput == PipeOutput {
  // Default intializer iff input and output types match
  init() {
    self.init(processor: { return $0 })
  }
}

// MARK: - Pipe

public typealias PipeType = protocol<Inputable, Outputable>

public class Pipe<Input,Output>: Processable, PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  // MARK: Processable
  
  public var processor: (PipeInput) -> PipeOutput
  public required init(processor: (PipeInput) -> PipeOutput) {
    self.processor = processor
  }
  
  public func process(input: PipeInput) -> PipeOutput {
    return processor(input)
  }
  
  // MARK: Inputable
  
  public func insert(input: PipeInput) {
    let output = self.process(input)
    for outputable in self.outputs {
      outputable.insert(output)
    }
  }
  
  // MARK: Outputable
  
  private var outputs = [CompatibleInputable<Output>]()
  public func connect<I : Inputable where I.PipeInput == PipeOutput>(inputable: I) -> Self {
    let inputableThunk = CompatibleInputable<Output>(inputable)
    self.outputs.append(inputableThunk)
    return self
  }
}

// MARK: - Operator

infix operator |- { associativity right precedence 100 }
func |- <PL: PipeType, PR: PipeType where PL.PipeOutput == PR.PipeInput> (var left: PL, right: PR) -> PL {
  return left.connect(right)
}

// MARK: - Thunk for supporting Type Erasure on Inputable

struct CompatibleInputable<Output>: Inputable {
  typealias CompatibleInput = Output
  
  init<I: Inputable where I.PipeInput == CompatibleInput>(_ inputable: I) {
    _insert = inputable.insert
  }
  
  private let _insert: (input: CompatibleInput) -> Void
  func insert(input: CompatibleInput) {
    _insert(input: input)
  }
}
