//
//  Pipeable.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

public protocol Pipeable {
  typealias DefaultPipeInput
  typealias DefaultPipeOutput

  func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput>
}

public extension Pipe {
  public convenience init<P: Pipeable where P.DefaultPipeOutput == Input>(pipeable: P, process: (Input) -> Output) {
    self.init(process: process)
    pipeable.pipe().connect(self)
  }
}
