//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

public struct ViewProperty<X: Equatable, Y:UIControl where Y:ControlType> {
  public var valuePipe: Observable<X>
  public var viewPipe: ControlPipe<Y>
  public var isValidPipe: AnyOutputable<Bool>
  
  public init(value: X, view: Y, setup: (value: AnyPipe<X,X>, view: AnyPipe<Y.ControlValueType,Y.ControlValueType>, isValid: AnyPipe<Bool, Bool>) -> Void) {
    let isValid = Observable<Bool>(true)
    valuePipe = Observable(value)
    viewPipe = ControlPipe(view)
    isValidPipe = AnyOutputable(isValid)
    
    let pipe1 = AnyPipe(valuePipe, weak: false)
    let pipe2 = AnyPipe(viewPipe, weak: true)
    setup(value: pipe1, view: pipe2, isValid: AnyPipe(isValid))
  }
  
  public var value: X {
    get {
      return valuePipe.value
    }
    set(value) {
      valuePipe.value = value
    }
  }
}

extension ViewProperty where X == Y.ControlValueType {
  public init (value: X, view: Y) {
    self.init(value: value, view: view) {
      (value, view, isValid) in
      value.connect(view)
      view.connect(value)
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
  var text: ViewProperty<String, UITextField>
  var number: ViewProperty<Int, UITextField>
  
  init(model: Model, view: CustomView) {
    text = ViewProperty(value: model.text, view: view.textField)
    number = ViewProperty(value: model.number, view: view.numberField) {
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

