//
//  Observable.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

final public class Observable<T:Equatable>: Pipeable {
  public typealias PipeInput = T
  public typealias PipeOutput = T
  
  private var inputPipe: Pipe<PipeInput,PipeOutput>
  private var outputPipe = Pipe<PipeInput,PipeOutput>()
  private var valueDidChange: Bool = false
  
  public var value: T {
    willSet (newValue) {
      valueDidChange = value != newValue
    }
    didSet {
      outputPipe.insert(value)
      valueDidChange = false
    }
  }
  
  // MARK: - Pipeable
  public var processor: (PipeInput) -> PipeOutput
  public var pipe: AnyPipe<PipeInput, PipeOutput>
  
  public init(_ value: T) {
    self.value = value
    self.processor = { return $0 }
    
    // 💩 `pipe` and `inputPipe` need to be initialized twice here otherwise the compiler will complain
    // about `self` being referenced before it is initialized
    let tempPipe = Pipe<PipeInput, PipeOutput>()
    pipe = AnyPipe(tempPipe)
    inputPipe = tempPipe
    
    // Set the obeserved property when receiving input from the pipe
    inputPipe = Pipe { [weak self] in
      self?.value = $0
      return $0
    }
    inputPipe.filter = { [weak self] in
      return self?.value != $0
    }
    
    // Only output if the value actually changed
    outputPipe.filter = { [weak self] (input: PipeInput) in
      return self?.valueDidChange ?? false
    }
    
    // Create a new pipe with the input and output _without_ connecting them.  The inputPipe will
    // mutate the `value` property which will in turn insert into outputPipe iff the value is different
    // This is to prevent multiple calls to insert for the same input.
    self.pipe = AnyPipe(input: inputPipe, output: outputPipe)
  }
}
