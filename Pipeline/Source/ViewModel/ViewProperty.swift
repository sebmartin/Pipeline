//
//  FormElement.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-29.
//  Copyright © 2016 Seb Martin. All rights reserved.
//


public struct ViewProperty<ValueType: Equatable, ViewType:UIControl> where ViewType:PipeableViewType {
  public var valuePipe: Observable<ValueType>
  public var viewPipe: ViewPipe<ViewType>
  public var isValidPipe: Observable<Bool>

  public init <
    ValuePipeType: PipeType,
    ViewPipeType: PipeType>
	(value: ValueType, view: ViewType, valueOut: ValuePipeType, viewOut: ViewPipeType, validator: Validator<ValueType>? = nil)
	where
    ValuePipeType.PipeInput == ValueType, ValuePipeType.PipeOutput == ViewType.ViewValueType,
    ViewPipeType.PipeInput == ViewType.ViewValueType, ViewPipeType.PipeOutput == ValueType
  {
    valuePipe = Observable(value)
    viewPipe = ViewPipe(view)
    isValidPipe = Observable(true)
    
    let validator = validator ?? Validator<ValueType> { (value) in return true }

    viewPipe |- viewOut |- validator |~ {
      $0 |- self.valuePipe |- valueOut |- AnyPipe(self.viewPipe, weak: true)
      $0.isValid |- self.isValidPipe
    }
  }
  
  public var value: ValueType {
    get {
      return valuePipe.value
    }
    set(value) {
      valuePipe.value = value
    }
  }
  
  public var view: ViewType {
    return viewPipe.view
  }
  
  // MARK: - Convenience initializers
  
  // MARK: View and Value Pipe/Lambda permutations
  
	public init <ViewPipeType: PipeType>
		(value: ValueType, view: ViewType, valueOut: @escaping (ValueType)->ViewType.ViewValueType, viewOut: ViewPipeType, validator: Validator<ValueType>? = nil) where ViewPipeType.PipeInput == ViewType.ViewValueType, ViewPipeType.PipeOutput == ValueType
  {
    let valuePipe = Pipe(valueOut)
    self.init(value: value, view: view, valueOut: valuePipe, viewOut: viewOut, validator: validator)
  }
  
	public init <ValuePipeType: PipeType>
		(value: ValueType, view: ViewType, valueOut: ValuePipeType, viewOut: @escaping (ViewType.ViewValueType)->(ValueType), validator: Validator<ValueType>? = nil) where ValuePipeType.PipeInput == ValueType, ValuePipeType.PipeOutput == ViewType.ViewValueType
  {
    let viewPipe = Pipe(viewOut)
    self.init(value: value, view: view, valueOut: valueOut, viewOut: viewPipe, validator: validator)
  }

  public init (value: ValueType, view: ViewType, valueOut: @escaping (ValueType)->ViewType.ViewValueType, viewOut: @escaping (ViewType.ViewValueType)->(ValueType), validator: Validator<ValueType>? = nil)
  {
    let valuePipe = Pipe(valueOut)
    let viewPipe = Pipe(viewOut)
    self.init(value: value, view: view, valueOut: valuePipe, viewOut: viewPipe, validator: validator)
  }
  
  // MARK: Validator as a lambda
  
  public init <
    ValuePipeType: PipeType,
    ViewPipeType: PipeType>
	(value: ValueType, view: ViewType, valueOut: ValuePipeType, viewOut: ViewPipeType, validator: @escaping (ValueType)->Bool)
	where
    ValuePipeType.PipeInput == ValueType, ValuePipeType.PipeOutput == ViewType.ViewValueType,
    ViewPipeType.PipeInput == ViewType.ViewValueType, ViewPipeType.PipeOutput == ValueType
  {
    self.init(value: value, view: view, valueOut: valueOut, viewOut: viewOut, validator: Validator(validate: validator))
  }
  
	public init <ViewPipeType: PipeType>
		(value: ValueType, view: ViewType, valueOut: @escaping (ValueType)->ViewType.ViewValueType, viewOut: ViewPipeType, validator: @escaping (ValueType)->Bool) where ViewPipeType.PipeInput == ViewType.ViewValueType, ViewPipeType.PipeOutput == ValueType
  {
    self.init(value: value, view: view, valueOut: valueOut, viewOut: viewOut, validator: Validator(validate: validator))
  }
  
	public init <ValuePipeType: PipeType>
		(value: ValueType, view: ViewType, valueOut: ValuePipeType, viewOut: @escaping (ViewType.ViewValueType)->(ValueType), validator: @escaping (ValueType)->Bool) where ValuePipeType.PipeInput == ValueType, ValuePipeType.PipeOutput == ViewType.ViewValueType
  {
    self.init(value: value, view: view, valueOut: valueOut, viewOut: viewOut, validator: Validator(validate: validator))
  }
  
  public init (value: ValueType, view: ViewType, valueOut: @escaping (ValueType)->ViewType.ViewValueType, viewOut: @escaping (ViewType.ViewValueType)->(ValueType), validator: @escaping (ValueType)->Bool)
  {
    self.init(value: value, view: view, valueOut: valueOut, viewOut: viewOut, validator: Validator(validate: validator))
  }
}

extension ViewProperty where ValueType == ViewType.ViewValueType {
  public init(value: ValueType, view: ViewType, validator: Validator<ValueType>? = nil) {
    self.init(value: value, view: view, valueOut: { return $0 }, viewOut: { return $0 }, validator: validator)
  }
  
  public init(value: ValueType, view: ViewType, validator: @escaping (ValueType)->Bool) {
    self.init(value: value, view: view, valueOut: { return $0 }, viewOut: { return $0 }, validator: Validator(validate: validator))
  }
}
