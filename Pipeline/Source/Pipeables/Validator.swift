//
//  Validator.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-04-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

class AnyValidatorType<ValueType>: ValidatorType {
  
  init<V: ValidatorType where V.ValueType == ValueType>(_ validator: V) {
    _pipe = { return validator.pipe }
    _isValid = { return validator.isValid }
  }
  
  private let _pipe: () -> AnyPipe<ValueType, ValueType>
  var pipe: AnyPipe<ValueType, ValueType> {
    return _pipe()
  }
  
  private let _isValid: () -> AnyPipe<ValueType, Bool>
  var isValid: AnyPipe<ValueType, Bool> {
    return _isValid()
  }
}

protocol ValidatorType: Pipeable {
  associatedtype ValueType
  associatedtype PipeInput = ValueType
  associatedtype PipeOutput = ValueType
  
  var pipe: AnyPipe<ValueType, ValueType> { get }
  var isValid: AnyPipe<ValueType, Bool> { get }
}

class Validator<ValueType>: ValidatorType {
  var pipe: AnyPipe<ValueType, ValueType>
  var isValid: AnyPipe<ValueType, Bool>
  
  init(validate: (value: ValueType) -> Bool) {
    let outputValue = AnyPipe(Pipe<ValueType, ValueType>())
    let outputIsValid = Observable(true)
    let input = Pipe {
      (input: ValueType) in
      if validate(value: input) {
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
