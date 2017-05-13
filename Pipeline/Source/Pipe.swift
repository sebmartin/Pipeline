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

  func insert(_ input: PipeInput)
}

public protocol Outputable: class, DescribablePipe {
  associatedtype PipeOutput
  
  func connect<I: Inputable>(_ inputable: I) where I.PipeInput == PipeOutput
}

public protocol Processable {
  associatedtype PipeInput
  associatedtype PipeOutput
  
  var processor: (PipeInput) -> PipeOutput { get }
  init(_ processor: @escaping (PipeInput) -> PipeOutput)
}

extension Processable where PipeInput == PipeOutput {
  // Default intializer iff input and output types match
  public init() {
    self.init({ return $0 })
  }
}

public protocol PipeType: Inputable, Outputable {
  func fuse<P: PipeType>(_ pipe: P) -> AnyPipe<PipeInput, P.PipeOutput> where P.PipeInput == PipeOutput
}

extension PipeType {
  public func fuse<P: PipeType>(_ pipe: P) -> AnyPipe<PipeInput, P.PipeOutput> where P.PipeInput == PipeOutput {
    self.connect(pipe)
    return AnyPipe(input: self, output: pipe)
  }
}

// MARK: - Pipe

public class Pipe<Input,Output>: Processable, PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  public var filter: (PipeInput) -> Bool = { (input) in true }
  
  // MARK: Processable
  
  public var processor: (PipeInput) -> PipeOutput
  public required init(_ processor: @escaping (PipeInput) -> PipeOutput) {
    self.processor = processor
  }
  
  public func process(_ input: PipeInput) -> PipeOutput {
    return processor(input)
  }
  
  // MARK: Inputable
  
  public func insert(_ input: PipeInput) {
    if !filter(input) {
      return
    }
    let output = self.process(input)
    for outputable in self.outputs {
      outputable.insert(output)
    }
  }
  
  // MARK: Outputable
  
  public var outputs = [AnyInputable<PipeOutput>]()
  public func connect<I : Inputable>(_ inputable: I) where I.PipeInput == PipeOutput {
    let inputableActual = inputable as? AnyInputable<Output> ?? AnyInputable(inputable)
    self.outputs.append(inputableActual)
  }
  
  // MARK: Description
  
  public var description: String {
    let address = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    return "\(type(of: self)) (\(address)) (outputs: \(self.outputs.count))"
  }
  
  public func recursiveDescription(_ seen: [String]=[]) -> String {
    var seen = seen
    seen.append("\(type(of: self))")
    let childDescriptions = outputs.reduce([String]()) {
      let address = "\(type(of: $1))"
      if seen.contains(address) {
        return $0 + ["\($1.description) ~~ CYCLE DETECTED"]
      }
      seen.append(address)
      return $0 + $1.recursiveDescription(seen).components(separatedBy: "\n")
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
  
  public init<I: Inputable>(_ inputable: I, weak: Bool = false) where I.PipeInput == Input {
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
  
  private let _insert: (Input) -> Void
  public func insert(_ input: Input) {
    _insert(input)
  }
  
  private let _description: () -> String
  public var description: String {
    get {
      return _description()
    }
  }
  
  private let _recursiveDescription: ([String]) -> String
  public func recursiveDescription(_ seen: [String]=[]) -> String {
    return _recursiveDescription(seen)
  }
}

public class AnyOutputable<Output>: Outputable {
  public typealias PipeOutput = Output
  
  public init<_Outputable: Outputable>(_ outputable: _Outputable, weak: Bool = false) where _Outputable.PipeOutput == Output {
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
  
  private var _connect: (AnyInputable<Output>) -> Void
  public func connect<I : Inputable>(_ inputable: I) where I.PipeInput == Output {
    _connect(AnyInputable(inputable))
  }
  
  private let _description: () -> String
  public var description: String {
    get {
      return _description()
    }
  }
  
  private let _recursiveDescription: ([String]) -> String
  public func recursiveDescription(_ seen: [String]=[]) -> String {
    return _recursiveDescription(seen)
  }
}

public class AnyPipe<Input, Output>: PipeType {
  public typealias PipeInput = Input
  public typealias PipeOutput = Output
  
  private let inputable: AnyInputable<Input>
  private let outputable: AnyOutputable<Output>
  
  public convenience init<P: PipeType>(_ pipe: P, weak: Bool = false) where P.PipeInput == Input, P.PipeOutput == Output {
    self.init(input: pipe, output: pipe, weak: weak)
  }
  
  public init<I: Inputable, O:Outputable>(input: I, output: O, weak: Bool = false) where I.PipeInput == PipeInput, O.PipeOutput == PipeOutput {
    self.inputable = AnyInputable(input, weak: weak)
    self.outputable = AnyOutputable(output, weak: weak)
  }
  
  public func insert(_ input: Input) {
    inputable.insert(input)
  }
  
  public func connect<I: Inputable>(_ inputable: I) where I.PipeInput == Output {
    outputable.connect(AnyInputable(inputable))
  }
  
  public var description: String {
    return inputable.description
  }
  
  public func recursiveDescription(_ seen: [String]=[]) -> String {
    return inputable.recursiveDescription(seen)
  }
}

// MARK: - DescribablePipe

public protocol DescribablePipe: CustomStringConvertible {
  func recursiveDescription(_ seen: [String]) -> String
}

extension DescribablePipe {
  var description: String {
    get {
      return recursiveDescription([])
    }
  }
}

// MARK: - Operator



precedencegroup Pipe {
  associativity: left
  lowerThan: CastingPrecedence
}
precedencegroup PipeFunction {
  associativity: left
  higherThan: Pipe
}

infix operator |-: Pipe
@discardableResult public func |- <LeftPipe: PipeType, RightPipe: PipeType>(left: LeftPipe, right: RightPipe) -> AnyPipe<LeftPipe.PipeInput, RightPipe.PipeOutput> where LeftPipe.PipeOutput == RightPipe.PipeInput {
  return left.fuse(right)
}

@discardableResult public func |- <X, Y, Z> (left: @escaping (X) -> Y, right: @escaping (Y) -> Z) -> AnyPipe<X, Z> {
  return Pipe(left) |- Pipe(right)
}

@discardableResult public func |- <X, Y, RightPipe: PipeType> (left: @escaping (X) -> Y, right: RightPipe) -> AnyPipe<X, RightPipe.PipeOutput> where RightPipe.PipeInput == Y {
  return Pipe(left) |- right
}

@discardableResult public func |- <Y, Z, LeftPipe: PipeType> (left: LeftPipe, right: @escaping (Y) -> Z) -> AnyPipe<LeftPipe.PipeInput, Z> where LeftPipe.PipeOutput == Y {
  return left |- Pipe(right)
}

infix operator |~: PipeFunction
@discardableResult public func |~ <X> (left: X, right: (X) -> ()) -> X {
  right(left)
  return left
}
