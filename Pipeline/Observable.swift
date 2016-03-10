//
//  Observable.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

struct Observable<T>: Outputable, Pipeable {
  typealias Output = T
  typealias DefaultPipeInput = T
  typealias DefaultPipeOutput = T
  
  internal let proxyPipe = Pipe<T,T>()

  init(_ value: T) {
    self.value = value
  }
  
  var value: T {
    didSet {
      proxyPipe.insert(value)
    }
  }
  
  mutating func connect<I: Inputable where I.Input == Output>(inputable: I) -> Observable<T> {
    proxyPipe.connect(inputable)
    return self
  }
  
  func pipe() -> Pipe<DefaultPipeInput, DefaultPipeOutput> {
    return proxyPipe
  }
}
