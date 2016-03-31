//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

struct FormElement<C: ControlType where C:UIControl, C.ControlValueType: Equatable> {
  var formBound: ControlPipe<C>?
  let dataBound: Observable<C.ControlValueType>
  
  init(data: C.ControlValueType) {
    dataBound = Observable(data)
  }
}





struct Model {
  var text: String
  var number: Int
}

class CustomView: UIView {
  var textField = UITextField()
  var numberField = UITextField()
}

struct ViewModel {
  var text: FormElement<UITextField>
  var number: FormElement<UITextField>
  
  init(model: Model) {
    text = FormElement(data: model.text)
    number = FormElement(data: "model.number")
  }
  
  var model: Model {
    set {
      text.dataBound.value = model.text
    }
    get {
      return Model(
        text: text.dataBound.value,
        number: 1 //number.dataBound.value
      )
    }
  }
  
  var view: CustomView? {
    didSet {
      if let view = self.view {
        text.formBound = ControlPipe(view.textField)
      }
    }
  }
}