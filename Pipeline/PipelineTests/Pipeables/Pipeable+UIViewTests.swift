//
//  Pipeable+UIViewTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-11.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import CoreData
import UIKit
import Pipeline

class ViewPipeTests: XCTestCase {
  
  // MARK: Generic tests
  
  func testViewPipesDoNotDeliverInputsThatMatchTheViewsCurrentValueToTheirOutputs() {
    let view = UITextField()
    let pipe = ViewPipe(view)
    var output: String?
    pipe |- Pipe {
      output = $0
    }
    
    view.text = "test"
    pipe.insert("test")
    
    XCTAssertNil(output)
  }
  
  func testViewPipesDeliverInputsToTheirOutputs() {
    let view = UITextField()
    let pipe = ViewPipe(view)
    var output: String?
    pipe |- Pipe
      {
      output = $0
    }
    
    view.text = ""
    pipe.insert("test")
    
    XCTAssertEqual(output, "test")
  }
  
  // MARK: UIDatePicker
  
  func testUIDatePickerOutputsDate() {
    let value = Date()
    let datePicker = UIDatePicker()
    var output: Date?
    let pipeline = ViewPipe(datePicker, events: .valueChanged) |- Pipe {
      (input: Date) in
      output = input
    }
    
    datePicker.date = value
    datePicker.sendActions(for: .valueChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIDatePickerDefaultsToValueChangedEvent() {
    let value = Date()
    let datePicker = UIDatePicker()
    var output: Date?
    let pipeline = datePicker |- Pipe {
      (input: Date) in
      output = input
    }
    
    datePicker.date = value
    datePicker.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIDatePickerUpdatesOnInput() {
    let value = Date()
    let datePicker = UIDatePicker()
    let pipeline = Pipe() |- ViewPipe(datePicker)
    
    pipeline.insert(value)
    
    XCTAssertEqual(datePicker.date, value)
  }
  
  func testUIDatePickerUpdatesOnInputDirect() {
    let value = Date()
    let datePicker = UIDatePicker()
    let pipeline = Pipe() |- datePicker
    
    pipeline.insert(value)
    
    XCTAssertEqual(datePicker.date, value)
  }
  
  // MARK: UIPageControl
  
  func testUIPageControlOutputsPageIndex() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    var output: Int?
    let pipeline = ViewPipe(pageControl, events: .editingChanged) |- Pipe {
      (input: Int) in
      output = input
    }
    
    pageControl.currentPage = value
    pageControl.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIPageControlDefaultsToEditingChangedEvent() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    var output: Int?
    let pipeline = pageControl |- Pipe {
      (input: Int) in
      output = input
    }
    
    pageControl.currentPage = value
    pageControl.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIPageControlUpdatesOnInput() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    let pipeline = Pipe() |- ViewPipe(pageControl)
    
    pipeline.insert(value)
    
    XCTAssertEqual(pageControl.currentPage, value)
  }
  
  func testUIPageControlUpdatesOnInputDirect() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    let pipeline = Pipe() |- pageControl
    
    pipeline.insert(value)
    
    XCTAssertEqual(pageControl.currentPage, value)
  }
  
  // MARK: UISlider
  
  func testUISliderOutputsValue() {
    let value = 0.7 as Float
    let view = UISlider()
    var output: Float?
    let pipeline = ViewPipe(view, events: .editingChanged) |- Pipe {
      (input: Float) in
      output = input
    }
    
    view.value = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderDefaultsToEditingChangedEvent() {
    let value = 0.7 as Float
    let view = UISlider()
    var output: Float?
    let pipeline = view |- Pipe {
      (input: Float) in
      output = input
    }
    
    view.value = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderUpdatesOnInput() {
    let value = 0.7 as Float
    let view = UISlider()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.value, value)
  }
  
  func testUISliderUpdatesOnInputDirect() {
    let value = 0.7 as Float
    let view = UISlider()
    let pipeline = Pipe() |- view
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.value, value)
  }
  
  // MARK: UIStepper
  
  func testUIStepperOutputsValue() {
    let value = 0.7 as Double
    let view = UIStepper()
    var output: Double?
    let pipeline = ViewPipe(view, events: .editingChanged) |- Pipe {
      (input: Double) in
      output = input
    }
    
    view.value = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperDefaultsToEditingChangedEvent() {
    let value = 0.7 as Double
    let view = UIStepper()
    var output: Double?
    let pipeline = view |- Pipe {
      (input: Double) in
      output = input
    }
    
    view.value = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperUpdatesOnInput() {
    let value = 0.7 as Double
    let view = UIStepper()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.value, value)
  }
  
  func testUIStepperUpdatesOnInputDirect() {
    let value = 0.7 as Double
    let view = UIStepper()
    let pipeline = Pipe() |- view
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.value, value)
  }
  
  // MARK: UISwitch
  
  func testUISwitchOutputsValue() {
    let value = true
    let view = UISwitch()
    var output: Bool?
    let pipeline = ViewPipe(view, events: .editingChanged) |- Pipe {
      (input: Bool) in
      output = input
    }
    
    view.isOn = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchDefaultsToEditingChangedEvent() {
    let value = true
    let view = UISwitch()
    var output: Bool?
    let pipeline = view |- Pipe {
      (input: Bool) in
      output = input
    }
    
    view.isOn = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchUpdatesOnInput() {
    let value = true
    let view = UISwitch()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.isOn, value)
  }
  
  func testUISwitchUpdatesOnInputDirect() {
    let value = true
    let view = UISwitch()
    let pipeline = Pipe() |- view
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.isOn, value)
  }
  
  // MARK: UITextField
  
  func testUITextFieldOutputsText() {
    let value = "Pipeline!"
    let view = UITextField()
    var output: String?
    let pipeline = ViewPipe(view, events: .editingChanged) |- Pipe {
      (input: String) in
      output = input
    }
    
    view.text = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldDefaultsToEditingChangedEvent() {
    let value = "Pipeline!"
    let view = UITextField()
    var output: String?
    let pipeline = view |- Pipe {
      (input: String) in
      output = input
    }
    
    view.text = value
    view.sendActions(for: .editingChanged)
    
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldWithNilTextOutputsAnEmptyString() {
    let view = UITextField()
    view.text = nil
    XCTAssertEqual(view.pipeableViewValue(), "")
  }
  
  func testUITextFieldUpdatesOnInput() {
    let value = "Pipeline!"
    let view = UITextField()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.text, value)
  }
  
  func testUITextFieldUpdatesOnInputDirect() {
    let value = "Pipeline!"
    let view = UITextField()
    let pipeline = Pipe() |- view
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.text, value)
  }
  
  // MARK: UILabel
  
  func testUILabelUpdatesOnInput() {
    let value = "Pipeline!"
    let view = UILabel()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.text, value)
  }
  
  // MARK: UIProgressView
  
  func testUIProgressViewUpdatesOnInput() {
    let value = 0.5 as Float
    let view = UIProgressView()
    let pipeline = Pipe() |- ViewPipe(view)
    
    pipeline.insert(value)
    
    XCTAssertEqual(view.progress, value)
  }
}
