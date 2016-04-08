//
//  Pipeable.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

public protocol Pipeable: PipeType {
  var pipe: AnyPipe<PipeInput, PipeOutput> { get }
}

extension Pipeable {
  public func insert(input: PipeInput) {
    pipe.insert(input)
  }
  
  public func connect<I : Inputable where I.PipeInput == PipeOutput>(inputable: I) {
    pipe.connect(inputable)
  }
}
