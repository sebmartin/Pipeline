//
//  Validator.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-04-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

public protocol ValidatorType: Pipeable {
  associatedtype ValueType
  associatedtype PipeInput = ValueType
  associatedtype PipeOutput = ValueType
  
  var pipe: AnyPipe<ValueType, ValueType> { get }
  var isValid: AnyPipe<ValueType, Bool> { get }
}

public class Validator<ValueType>: ValidatorType {
  public typealias PipeInput = ValueType
  public typealias PipeOutput = ValueType
  public var pipe: AnyPipe<ValueType, ValueType>
  public var isValid: AnyPipe<ValueType, Bool>
  
  public init(validate: @escaping (ValueType) -> Bool) {
    let outputValue = AnyPipe(Pipe<ValueType, ValueType>())
    let outputIsValid = Observable(true)
    let input = Pipe {
      (input: ValueType) in
      if validate(input) {
        outputValue.insert(input)
        outputIsValid.insert(true)
      } else {
        outputIsValid.insert(false)
      }
    }
    self.pipe = AnyPipe(input: input, output: outputValue)
    self.isValid = AnyPipe(input: input, output: outputIsValid)
  }
}
