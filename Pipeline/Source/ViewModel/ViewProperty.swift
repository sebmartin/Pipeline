//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

public struct ViewProperty<X: Equatable, Y:UIControl where Y:PipeableViewType> {
  public var valuePipe: Observable<X>
  public var viewPipe: ViewPipe<Y>
  public var isValidPipe: AnyOutputable<Bool>
  
  public init(value: X, view: Y, setup: (value: AnyPipe<X,X>, view: AnyPipe<Y.ViewValueType,Y.ViewValueType>, isValid: AnyPipe<Bool, Bool>) -> Void) {
    let isValid = Observable<Bool>(true)
    valuePipe = Observable(value)
    viewPipe = ViewPipe(view)
    isValidPipe = AnyOutputable(isValid)
    
    let pipe1 = AnyPipe(valuePipe, weak: false)
    let pipe2 = AnyPipe(viewPipe, weak: true)
    setup(value: pipe1, view: pipe2, isValid: AnyPipe(isValid))
    
    valuePipe.pump()
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

extension ViewProperty where X == Y.ViewValueType {
  public init (value: X, view: Y) {
    self.init(value: value, view: view) {
      (value, view, isValid) in
      value.connect(view)
      view.connect(value)
    }
  }
}
