//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

struct FormElement<X: Equatable, Y:UIControl where Y:ControlType> {
  var dataPipe: Observable<X>
  var controlPipe = nil as ControlPipe<Y>?
  var controlProxyPipe = Pipe<Y.ControlValueType,Y.ControlValueType>()
  
  init(value: X, connect: (dataPipe: AnyPipe<X,X>, controlPipe: AnyPipe<Y.ControlValueType,Y.ControlValueType>) -> Void ) {
    dataPipe = Observable(value)
    connect(dataPipe: AnyPipe(dataPipe, weak: true), controlPipe: AnyPipe(controlProxyPipe, weak: false))
  }
  
  var value: X {
    get {
      return dataPipe.value
    }
    set(value) {
      dataPipe.value = value
    }
  }
  
  mutating func bindTo(control: Y) {
    let controlPipe = ControlPipe(control)
    controlProxyPipe.connect(AnyPipe(controlPipe, weak: true))
    controlPipe.connect(controlProxyPipe)
    self.controlPipe = controlPipe
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
  
  init(model: Model) {
    text = FormElement(value: model.text) {
      $0 |- $1
      $1 |- $0
    }
    number = FormElement(value: model.number) { (data, control) in
      control |- { (input: String) in return 0 } |- data
      data |- { return "\($0)" } |- control
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
  
  mutating func bindTo(view: CustomView) {
    text.bindTo(view.textField)
    text.bindTo(view.numberField)
  }
}

