//
//  Observable.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

final public class Observable<T where T:Equatable>: Pipeable {
  public typealias PipeInput = T
  public typealias PipeOutput = T
  
  private var previousValue: T?
  var value: T {
    willSet (newValue) {
      previousValue = value
    }
    didSet {
      if previousValue != value {
        pipe.insert(value)
      }
      previousValue = nil
    }
  }
  
  // MARK: - Pipeable
  public var processor: (PipeInput) -> PipeOutput
  public var pipe: AnyPipe<PipeInput, PipeOutput>
  
  public init(_ value: T) {
    self.value = value
    self.processor = { return $0 }
    
    // 💩 `pipe` needs to be initialized twice here otherwise the compiler will complain
    // about `self` being referenced before it is initialized
    var pipe = Pipe<PipeInput, PipeOutput>()
    self.pipe = AnyPipe(pipe)
    
    pipe = Pipe { [weak self] (input:PipeInput) -> PipeOutput in
      self?.value = input
      return input
    }
    self.pipe = AnyPipe(pipe)
    
    self.insert(value)
  }
}
