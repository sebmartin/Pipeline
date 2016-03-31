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
  
  func connect<I: Inputable where I.PipeInput == PipeOutput>(inputable: I) -> Self
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
  
  private var outputs = [AnyInputable<Output>]()
  public func connect<I : Inputable where I.PipeInput == PipeOutput>(inputable: I) -> Self {
    let inputableThunk = AnyInputable<Output>(inputable)
    self.outputs.append(inputableThunk)
    return self
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
    _connect = { outputable.connect($0) }
  }
  
  private var _connect: (inputable: AnyInputable<Output>) -> Void
  public func connect<I : Inputable where I.PipeInput == Output>(inputable: I) -> Self {
    _connect(inputable: AnyInputable(inputable))
    return self
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
    if weak {
      weakInputable = AnyInputable(pipe)
      weakOutputable = AnyOutputable(pipe)
      inputable = nil
      outputable = nil
    } else {
      inputable = AnyInputable(pipe)
      outputable = AnyOutputable(pipe)
    }
  }
  
  public func insert(input: Input) {
    (inputable ?? weakInputable)?.insert(input)
  }

  public func connect<I: Inputable where I.PipeInput == Output>(inputable: I) -> AnyPipe<Input, Output> {
    (outputable ?? weakOutputable)?.connect(AnyInputable(inputable))
    return self
  }
}

// MARK: - Operator

infix operator |- { associativity right precedence 100 }
public func |- <Left: Outputable, Right: Inputable where Left.PipeOutput == Right.PipeInput>(left: Left, right: Right) -> Left {
  return left.connect(right)
}

public func |- <Left: PipeType, Right: Inputable where Left.PipeOutput == Right.PipeInput>(left: Left, right: Right) -> Left {
  return left.connect(right)
}

public func |- <X, Y, Z> (left: (X) -> Y, right: (Y) -> Z) -> AnyPipe<X, Y> {
  return AnyPipe(Pipe(processor: left)) |- AnyInputable(Pipe(processor: right))
}

public func |- <X, Y, Right: Inputable where Right.PipeInput == Y> (left: (X) -> Y, right: Right) -> AnyPipe<X, Y> {
  return AnyPipe(Pipe(processor: left)) |- right
}

public func |- <Y, Z, Left: Outputable where Left.PipeOutput == Y> (left: Left, right: (Y) -> Z) -> Left {
  return left |- AnyInputable(Pipe(processor: right))
}
