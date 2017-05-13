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
  public func insert(_ input: PipeInput) {
    pipe.insert(input)
  }
  
  public func connect<I : Inputable>(_ inputable: I) where I.PipeInput == PipeOutput {
    pipe.connect(inputable)
  }
  
  public var description: String {
    get { return pipe.description }
  }
  
  public func recursiveDescription(_ seen: [String]=[]) -> String {
    return pipe.recursiveDescription(seen)
  }
}
