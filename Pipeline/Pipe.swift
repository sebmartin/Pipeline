//
//  PipeLineTests2.swift
//  Reading
//
//  Created by Seb Martin on 2016-03-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

// MARK: - Protocols

public protocol Inputable {
  associatedtype PipeInput

  func insert(input: PipeInput)
}

public protocol Outputable {
  associatedtype PipeOutput
  
  func connect<I: Inputable where I.PipeInput == PipeOutput>(inputable: I)
}

public protocol Processable {
  
  associatedtype PipeInput
  associatedtype PipeOutput
  
  var processor: (PipeInput) -> PipeOutput { get }
  init(processor: (PipeInput) -> PipeOutput)
}

extension Processable where PipeInput == PipeOutput {
  // Default intializer iff input and output types match
  public init() {
    self.init(processor: { return $0 })
  }
}

// MARK: - Pipe

public protocol PipeType: Inputable, Outputable {
  func fuse<P: PipeType where P.PipeInput == PipeOutput>(pipe: P) -> AnyPipe<PipeInput, P.PipeOutput>
}

extension PipeType {
  public func fuse<P: PipeType where P.PipeInput == PipeOutput>(pipe: P) -> AnyPipe<PipeInput, P.PipeOutput> {
    self.connect(pipe)
    return AnyPipe(input: self, output: pipe)
  }
}

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
  
  private var outputs = [AnyInputable<Output>]()
  public func connect<I : Inputable where I.PipeInput == PipeOutput>(inputable: I) {
    let inputableThunk = AnyInputable<Output>(inputable)
    self.outputs.append(inputableThunk)
  }
}

// MARK: - Thunks for Type Erasure on Inputable

public class AnyInputable<Input>: Inputable {
  public typealias PipeInput = Input
  
  public init<I: Inputable where I.PipeInput == Input>(_ inputable: I) {
    _insert = inputable.insert
  }
  
  private let _insert: (input: Input) -> Void
  public func insert(input: Input) {
    _insert(input: input)
  }
}

public class AnyOutputable<Output>: Outputable {
  public typealias PipeOutput = Output
  
  public init<_Outputable: Outputable where _Outputable.PipeOutput == Output>(_ outputable: _Outputable) {
    _connect = outputable.connect
  }
  
  private var _connect: (inputable: AnyInputable<Output>) -> Void
  public func connect<I : Inputable where I.PipeInput == Output>(inputable: I) {
    _connect(inputable: AnyInputable(inputable))
  }
}

public struct AnyPipe<Input, Output>: PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  private let inputable: AnyInputable<Input>?
  private weak var weakInputable: AnyInputable<Input>? = nil
  private let outputable: AnyOutputable<Output>?
  private weak var weakOutputable: AnyOutputable<Output>? = nil
  
  public init<P: PipeType where P.PipeInput == Input, P.PipeOutput == Output>(_ pipe: P, weak: Bool = false) {
    self.init(input: pipe, output: pipe, weak: weak)
  }
  
  public init<I: Inputable, O:Outputable where I.PipeInput == PipeInput, O.PipeOutput == PipeOutput>(input: I, output: O, weak: Bool = false) {
    self.init(inputable: AnyInputable(input), outputable: AnyOutputable(output), weak: weak)
  }
  
  public init(inputable: AnyInputable<PipeInput>, outputable: AnyOutputable<PipeOutput>, weak: Bool = false) {
    if weak {
      weakInputable = inputable
      weakOutputable = outputable
      self.inputable = nil
      self.outputable = nil
    } else {
      self.inputable = inputable
      self.outputable = outputable
    }
  }
  
  public func insert(input: Input) {
    (inputable ?? weakInputable)?.insert(input)
  }

  public func connect<I: Inputable where I.PipeInput == Output>(inputable: I) {
    (outputable ?? weakOutputable)?.connect(AnyInputable(inputable))
  }
}

// MARK: - Operator

infix operator |- { associativity left precedence 100 }
public func |- <Left: PipeType, Right: PipeType where Left.PipeOutput == Right.PipeInput>(left: Left, right: Right) -> AnyPipe<Left.PipeInput, Right.PipeOutput> {
  return left.fuse(right)
}

public func |- <X, Y, Z> (left: (X) -> Y, right: (Y) -> Z) -> AnyPipe<X, Z> {
  return Pipe(processor: left) |- Pipe(processor: right)
}

public func |- <X, Y, Right: PipeType where Right.PipeInput == Y> (left: (X) -> Y, right: Right) -> AnyPipe<X, Right.PipeOutput> {
  return Pipe(processor: left) |- right
}

public func |- <Y, Z, Left: PipeType where Left.PipeOutput == Y> (left: Left, right: (Y) -> Z) -> AnyPipe<Left.PipeInput, Z> {
  return left |- Pipe(processor: right)
}
