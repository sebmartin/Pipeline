//
//  PipeLineTests2.swift
//  Reading
//
//  Created by Seb Martin on 2016-03-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

// MARK: Protocols

public protocol Inputable {
  typealias Input
  
  func insert(input: Input)
}

public protocol Outputable {
  typealias Output
  
  mutating func connect<I: Inputable where I.Input == Output>(inputable: I) -> Self
}

public protocol Processable {
  typealias Input
  typealias Output
  init(process: (Input) -> Output)
}

extension Processable where Input == Output {
  init() {
    self.init { return $0 }
  }
}

// MARK: Pipe

public class Pipe<X,Y>: Inputable, Outputable, Processable {
  public typealias Input = X
  public typealias Output = Y
  
  let process: (Input) -> Output
  public required init(process: (Input) -> Output) {
    self.process = process
  }
  
  private var outputs = [CompatibleInputable<Output>]()
  public func insert(input: Input) {
    let output = self.process(input)
    for outputable in self.outputs {
      outputable.insert(output)
    }
  }
  
  public func connect<I : Inputable where I.Input == Output>(inputable: I) -> Self {
    let inputableThunk = CompatibleInputable<Output>(inputable)
    self.outputs.append(inputableThunk)
    return self
  }
}

public class Drain<X>: Inputable {
  public typealias Input = X
  
  let process: (Input) -> Void
  public required init(process: (Input) -> Void) {
    self.process = process
  }
  
  public func insert(input: Input) {
    self.process(input)
  }
}

// MARK: Thunk for supporting Type Erasure on Inputable

private struct CompatibleInputable<Output>: Inputable {
  typealias CompatibleInput = Output
  
  init<I: Inputable where I.Input == CompatibleInput>(_ inputable: I) {
    _insert = inputable.insert
  }
  
  private let _insert: (input: CompatibleInput) -> Void
  func insert(input: CompatibleInput) {
    _insert(input: input)
  }
}
