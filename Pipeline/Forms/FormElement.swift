//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

struct AnyValidatorType<ValueType>: ValidatorType {
  
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

struct Validator<ValueType>: ValidatorType {
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

struct FormElement<X: Equatable, Y:UIControl where Y:ControlType> {
  var valuePipe: Observable<X>
  var viewPipe: ControlPipe<Y>
  var isValidPipe = Observable(true)
  
  typealias SetupFunction = (value: AnyPipe<X,X>, view: AnyPipe<Y.ControlValueType,Y.ControlValueType>, isValid: AnyPipe<Bool, Bool>) -> Void
  
  init(value: X, view: Y, setup: SetupFunction) {
    valuePipe = Observable(value)
    viewPipe = ControlPipe(view)
    setup(value: AnyPipe(valuePipe, weak: true), view: AnyPipe(viewPipe, weak: false), isValid: AnyPipe(isValidPipe))
  }
  
  var value: X {
    get {
      return valuePipe.value
    }
    set(value) {
      valuePipe.value = value
    }
  }
}

extension FormElement where X == Y.ControlValueType {
  init (value: X, view: Y) {
    self.init(value: value, view: view) {
      (value, view, isValid) in
      value |- view
      view |- value
    }
  }
}

// MARK: - Testsss

struct Model {
  var text: String
  var number: Int
}

class CustomView: UIView {
  var textField = UITextField()
  var numberField = UITextField()
}

struct ViewModel {
  var text: FormElement<String, UITextField>
  var number: FormElement<Int, UITextField>
  
  init(model: Model, view: CustomView) {
    text = FormElement(value: model.text, view: view.textField)
    number = FormElement(value: model.number, view: view.numberField) {
      (value, view, isValid) in
      value |- { "\($0)" } |- view
      view |- { Int($0) ?? 0 } |- value
    }
  }

  var model: Model {
    get {
      return Model(
        text: text.value,
        number: number.value
      )
    }
  }
}

