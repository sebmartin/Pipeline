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

func |- <PL: Pipeable, PR: Pipeable where PL.DefaultPipeOutput == PR.DefaultPipeInput> (left: PL, right: PR) -> Pipe<PL.DefaultPipeInput,PL.DefaultPipeOutput> {
  return left.pipe().connect(right.pipe())
}

func |- <PL: Pipeable, X, Y where PL.DefaultPipeOutput == X> (left: PL, right: Pipe<X,Y>) -> Pipe<PL.DefaultPipeInput,PL.DefaultPipeOutput> {
  return left.pipe().connect(right)
}

func |- <PL: Pipeable, Output where PL.DefaultPipeOutput == Output> (left: PL, right: Drain<Output>) -> Pipe<PL.DefaultPipeInput,PL.DefaultPipeOutput> {
  return left.pipe().connect(right)
}
