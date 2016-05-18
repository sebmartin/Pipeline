//
//  PipeLineTests2.swift
//  Reading
//
//  Created by Seb Martin on 2016-03-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

// MARK: - Protocols

public protocol Inputable: class, DescribablePipe {
  associatedtype PipeInput

  func insert(input: PipeInput)
}

public protocol Outputable: class, DescribablePipe {
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

public protocol PipeType: Inputable, Outputable {
  func fuse<P: PipeType where P.PipeInput == PipeOutput>(pipe: P) -> AnyPipe<PipeInput, P.PipeOutput>
}

extension PipeType {
  public func fuse<P: PipeType where P.PipeInput == PipeOutput>(pipe: P) -> AnyPipe<PipeInput, P.PipeOutput> {
    self.connect(pipe)
    return AnyPipe(input: self, output: pipe)
  }
}

// MARK: - Pipe

public class Pipe<Input,Output>: Processable, PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  public var filter: (input: PipeInput) -> Bool = { (input) in true }
  
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
    if !filter(input: input) {
      return
    }
    let output = self.process(input)
    for outputable in self.outputs {
      outputable.insert(output)
    }
  }
  
  // MARK: Outputable
  
  public var outputs = [AnyInputable<PipeOutput>]()
  public func connect<I : Inputable where I.PipeInput == PipeOutput>(inputable: I) {
    let inputableActual = inputable as? AnyInputable<Output> ?? AnyInputable(inputable)
    self.outputs.append(inputableActual)
  }
  
  // MARK: Description
  
  public var description: String {
    return "\(self.dynamicType) (\(unsafeAddressOf(self))) (outputs: \(self.outputs.count))"
  }
  
  public func recursiveDescription(seen: [String]) -> String {
    var seen = seen
    seen.append(self.description)
    let childDescriptions = outputs
      .filter {
        let address = $0.description
        if seen.contains(address) {
          return false
        }
        seen.append(address)
        return true
      }
      .reduce([]) {
        return $0 + $1.recursiveDescription(seen).characters.split("\n").map { (chars) in "\(chars)" }
      }
    var description = self.description
    if childDescriptions.count > 0 {
      let innerBlock = childDescriptions.reduce("") { $0 + "\n  \($1)"}
      description += ": \(innerBlock)"
    }
    return description
  }
}

// MARK: - Thunks for Type Erasure on Inputable

public class AnyInputable<Input>: Inputable {
  public typealias PipeInput = Input
  
  public init<I: Inputable where I.PipeInput == Input>(_ inputable: I, weak: Bool = false) {
    weak var weakInputable = inputable
    if weak {
      _insert = { weakInputable?.insert($0) }
      _description = { weakInputable?.description ?? "(deallocated weak reference)" }
      _recursiveDescription = { weakInputable?.recursiveDescription($0) ?? "(deallocated weak reference)" }

    } else {
      _insert = { inputable.insert($0) }
      _description = { inputable.description }
      _recursiveDescription = { inputable.recursiveDescription($0) }
    }
  }
  
  private let _insert: (input: Input) -> Void
  public func insert(input: Input) {
    _insert(input: input)
  }
  
  private let _description: () -> String
  public var description: String {
    get {
      return _description()
    }
  }
  
  private let _recursiveDescription: ([String]) -> String
  public func recursiveDescription(seen: [String]) -> String {
    return _recursiveDescription(seen)
  }
}

public class AnyOutputable<Output>: Outputable {
  public typealias PipeOutput = Output
  
  public init<_Outputable: Outputable where _Outputable.PipeOutput == Output>(_ outputable: _Outputable, weak: Bool = false) {
    weak var weakOutputable = outputable
    if weak {
      _connect = { weakOutputable?.connect($0) }
      _description = { weakOutputable?.description ?? "(deallocated weak reference)" }
      _recursiveDescription = { weakOutputable?.recursiveDescription($0) ?? "(deallocated weak reference)" }

    } else {
      _connect = { outputable.connect($0) }
      _description = { outputable.description }
      _recursiveDescription = { outputable.recursiveDescription($0) }
    }
  }
  
  private var _connect: (inputable: AnyInputable<Output>) -> Void
  public func connect<I : Inputable where I.PipeInput == Output>(inputable: I) {
    _connect(inputable: AnyInputable(inputable))
  }
  
  private let _description: () -> String
  public var description: String {
    get {
      return _description()
    }
  }
  
  private let _recursiveDescription: ([String]) -> String
  public func recursiveDescription(seen: [String]) -> String {
    return _recursiveDescription(seen)
  }
}

public class AnyPipe<Input, Output>: PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  private let inputable: AnyInputable<Input>
  private let outputable: AnyOutputable<Output>
  
  public convenience init<P: PipeType where P.PipeInput == Input, P.PipeOutput == Output>(_ pipe: P, weak: Bool = false) {
    self.init(input: pipe, output: pipe, weak: weak)
  }
  
  public init<I: Inputable, O:Outputable where I.PipeInput == PipeInput, O.PipeOutput == PipeOutput>(input: I, output: O, weak: Bool = false) {
    self.inputable = AnyInputable(input, weak: weak)
    self.outputable = AnyOutputable(output, weak: weak)
  }
  
  public func insert(input: Input) {
    inputable.insert(input)
  }
  
  public func connect<I: Inputable where I.PipeInput == Output>(inputable: I) {
    outputable.connect(AnyInputable(inputable))
  }
  
  public var description: String {
    return inputable.description
  }
  
  public func recursiveDescription(seen: [String]) -> String {
    return inputable.recursiveDescription(seen)
  }
}

// MARK: - DescribablePipe

public protocol DescribablePipe: CustomStringConvertible {
  func recursiveDescription(seen: [String]) -> String
}

extension DescribablePipe {
  var description: String {
    get {
      return recursiveDescription([])
    }
  }
}

// MARK: - Operator

infix operator |- { associativity left precedence 100 }
public func |- <LeftPipe: PipeType, RightPipe: PipeType where LeftPipe.PipeOutput == RightPipe.PipeInput>(left: LeftPipe, right: RightPipe) -> AnyPipe<LeftPipe.PipeInput, RightPipe.PipeOutput> {
  return left.fuse(right)
}

public func |- <X, Y, Z> (left: (X) -> Y, right: (Y) -> Z) -> AnyPipe<X, Z> {
  return Pipe(processor: left) |- Pipe(processor: right)
}

public func |- <X, Y, RightPipe: PipeType where RightPipe.PipeInput == Y> (left: (X) -> Y, right: RightPipe) -> AnyPipe<X, RightPipe.PipeOutput> {
  return Pipe(processor: left) |- right
}

public func |- <Y, Z, LeftPipe: PipeType where LeftPipe.PipeOutput == Y> (left: LeftPipe, right: (Y) -> Z) -> AnyPipe<LeftPipe.PipeInput, Z> {
  return left |- Pipe(processor: right)
}

infix operator |~ { associativity left precedence 101 }
public func |~ <X> (left: X, right: (X) -> ()) -> X {
  right(left)
  return left
}

// TODO: See if I can fuse an outputable to a pipe with the resulting type being AnyType<Void, X>.  That way I can fuse 
//   the validation status in FormElement
