//
//  Pipeable+UIView.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-09.
//  Copyright © 2016 Seb Martin. All rights reserved.
//
public class ViewPipe<View>: Pipeable, PipeType where View:PipeableViewType, View.ViewValueType: Equatable {
  public typealias PipeInput = View.ViewValueType
  public typealias PipeOutput = View.ViewValueType

  public let view: View
  public var pipe: AnyPipe<PipeInput, PipeOutput>
  private var target: Target? = nil
  
  public required init(_ view: View, events: UIControlEvents=UIControlEvents.editingChanged) {
    self.view = view
    
    let inputPipe = Pipe<PipeInput, PipeOutput> {
      view.setPipeableViewValue($0)
      return $0
    }
    inputPipe.filter = {
      view.pipeableViewValue() != $0
    }
    
    let outputPipe = Pipe<PipeInput, PipeOutput> {
      return $0
    }
    
    inputPipe.connect(outputPipe)
    self.pipe = AnyPipe(input: inputPipe, output: outputPipe)
    
    if let control = view as? UIControl {
      let target = Target()
      self.target = target
      target.handler = {
        outputPipe.insert(view.pipeableViewValue())
      }
      control.addTarget(target, action: #selector(Target.onControlEvent), for: events)
    }
  }
}

// A UIControl's Target needs to be an NSObject subclass
class Target: NSObject {
  var handler: (() -> Void)?
  func onControlEvent(event: UIEvent) {
    handler?()
  }
}

// MARK: - Operator

public func |- <V: PipeableViewType, P: PipeType> (left: V, right: P) -> AnyPipe<V.ViewValueType, P.PipeOutput> where V: UIView, P.PipeInput == V.ViewValueType {
  return ViewPipe(left) |- right
}

public func |- <P: PipeType, V: PipeableViewType> (left: P, right: V) -> AnyPipe<P.PipeInput, V.ViewValueType> where V: UIView, P.PipeOutput == V.ViewValueType {
  return left.fuse(ViewPipe(right))
}

// MARK: - Pipeable View Type Definition

public protocol PipeableViewType {
  associatedtype ViewValueType: Equatable
  associatedtype PipeInput = ViewValueType
  associatedtype PipeOutput = ViewValueType
  
  func pipeableViewValue() -> ViewValueType
  func setPipeableViewValue(_ value: ViewValueType)
}

// MARK: - Pipeable View Type Extensions

extension UIDatePicker: PipeableViewType {
  public typealias ViewValueType = Date
  
  public func pipeableViewValue() -> ViewValueType {
    return self.date
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.date = value
  }
}

extension UIPageControl: PipeableViewType {
  public typealias ViewValueType = Int
  
  public func pipeableViewValue() -> ViewValueType {
    return self.currentPage
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.currentPage = value
  }
}

extension UISlider: PipeableViewType {
  public typealias ViewValueType = Float
  
  public func pipeableViewValue() -> ViewValueType {
    return self.value
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.value = value
  }
}

extension UIStepper: PipeableViewType {
  public typealias ViewValueType = Double
  
  public func pipeableViewValue() -> ViewValueType {
    return self.value
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.value = value
  }
}

extension UISwitch: PipeableViewType {
  public typealias ViewValueType = Bool
  
  public func pipeableViewValue() -> ViewValueType {
    return self.isOn
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.isOn = value
  }
}

extension UITextField: PipeableViewType {
  public typealias ViewValueType = String
  
  public func pipeableViewValue() -> ViewValueType {
    return self.text! // getter never returns nil
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.text = value
  }
}

extension UILabel: PipeableViewType {
  public typealias ViewValueType = String
  
  public func pipeableViewValue() -> ViewValueType {
    return self.text ?? ""
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.text = value
  }
}

extension UIProgressView: PipeableViewType {
  public typealias ViewValueType = Float
  
  public func pipeableViewValue() -> ViewValueType {
    return self.progress
  }
  public func setPipeableViewValue(_ value: ViewValueType) {
    self.progress = value
  }
}
