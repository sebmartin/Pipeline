//
//  PipelineOperator.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-08.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

infix operator |- { associativity right precedence 100 }

func |- <A,B,C> (left: Pipe<A,B>, right: Pipe<B,C>) -> Pipe<A,B> {
  return left.connect(right)
}

func |- <A,B> (left: Pipe<A,B>, right: Drain<B>) -> Pipe<A,B> {
  return left.connect(right)
}