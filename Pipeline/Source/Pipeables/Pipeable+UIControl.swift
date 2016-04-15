//
//  Pipeable+UIControl.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

final public class ControlPipe<Control where Control:ControlType, Control:UIControl, Control.ControlValueType: Equatable>: Pipeable, PipeType {
  public typealias PipeInput = Control.ControlValueType
  public typealias PipeOutput = Control.ControlValueType

  private let control: Control
  public var pipe: AnyPipe<PipeInput, PipeOutput>
  private let target = Target<Control>()
  
  public required init(_ control: Control, events: UIControlEvents=UIControlEvents.EditingChanged) {
    self.control = control
    
    let outputPipe = Pipe<PipeInput, PipeOutput> {
      return $0
    }
    let inputPipe = Pipe<PipeInput, PipeOutput> {
      control.setControlValue($0)
      return $0
    }
    inputPipe.filter = {
      control.controlValue() != $0
    }
    self.pipe = AnyPipe(input: inputPipe, output: outputPipe)
    
    self.target.handler = {
      print("Fuck \(control.controlValue())")
      outputPipe.insert(control.controlValue())
    }
    self.control.addTarget(self.target, action: #selector(Target<Control>.onControlEvent), forControlEvents: events)
  }
}

// A UIControl's Target needs to be an NSObject subclass
public class Target<Control where Control:ControlType, Control:UIControl, Control.ControlValueType: Equatable>: NSObject {
  var handler: (() -> Void)?
  public func onControlEvent() {
    handler?()
  }
}

// MARK: - Operator

public func |- <C: ControlType, P: PipeType where C: UIControl, P.PipeInput == C.ControlValueType> (left: C, right: P) -> AnyPipe<C.ControlValueType, P.PipeOutput> {
  return ControlPipe(left) |- right
}

public func |- <P: PipeType, C: ControlType where C: UIControl, P.PipeOutput == C.ControlValueType> (left: P, right: C) -> AnyPipe<P.PipeInput, C.ControlValueType> {
  return left.fuse(ControlPipe(right))
}

// MARK: - Control Type Definition

public protocol ControlType {
  associatedtype ControlValueType: Equatable
  associatedtype PipeInput = ControlValueType
  associatedtype PipeOutput = ControlValueType
  
  func controlValue() -> ControlValueType
  func setControlValue(value: ControlValueType)
}

// MARK: - Control Type Extensions

extension UIDatePicker: ControlType {
  public typealias ControlValueType = NSDate
  
  public func controlValue() -> ControlValueType {
    return self.date
  }
  public func setControlValue(value: ControlValueType) {
    self.date = value
  }
}

extension UIPageControl: ControlType {
  public typealias ControlValueType = Int
  
  public func controlValue() -> ControlValueType {
    return self.currentPage
  }
  public func setControlValue(value: ControlValueType) {
    self.currentPage = value
  }
}

extension UISlider: ControlType {
  public typealias ControlValueType = Float
  
  public func controlValue() -> ControlValueType {
    return self.value
  }
  public func setControlValue(value: ControlValueType) {
    self.value = value
  }
}

extension UIStepper: ControlType {
  public typealias ControlValueType = Double
  
  public func controlValue() -> ControlValueType {
    return self.value
  }
  public func setControlValue(value: ControlValueType) {
    self.value = value
  }
}

extension UISwitch: ControlType {
  public typealias ControlValueType = Bool
  
  public func controlValue() -> ControlValueType {
    return self.on
  }
  public func setControlValue(value: ControlValueType) {
    self.on = value
  }
}

extension UITextField: ControlType {
  public typealias ControlValueType = String
  
  public func controlValue() -> ControlValueType {
    return self.text ?? ""
  }
  public func setControlValue(value: ControlValueType) {
    self.text = value
  }
}
