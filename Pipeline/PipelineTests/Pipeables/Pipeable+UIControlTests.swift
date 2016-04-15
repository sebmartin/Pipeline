//
//  Pipeable+UIControlTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-03-11.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import CoreData
import UIKit
import Pipeline

class ControlPipeTests: XCTestCase {
  
  // MARK: UIDatePicker
  
  func testUIDatePickerOutputsDate() {
    let value = NSDate()
    let datePicker = UIDatePicker()
    var output: NSDate?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(datePicker, events: .ValueChanged) |- Pipe {
      (input: NSDate) in
      output = input
      expectation.fulfill()
    }
    
    datePicker.date = value
    datePicker.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIDatePickerDefaultsToValueChangedEvent() {
    let value = NSDate()
    let datePicker = UIDatePicker()
    var output: NSDate?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = datePicker |- Pipe {
      (input: NSDate) in
      output = input
      expectation.fulfill()
    }
    
    datePicker.date = value
    datePicker.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIDatePickerUpdatesOnInput() {
    let value = NSDate()
    let datePicker = UIDatePicker()
    let pipeline = Pipe() |- ControlPipe(datePicker)
    
    pipeline.insert(value)
    
    XCTAssertEqual(datePicker.date, value)
  }
  
  func testUIDatePickerUpdatesOnInputDirect() {
    let value = NSDate()
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
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(pageControl, events: .EditingChanged) |- Pipe {
      (input: Int) in
      output = input
      expectation.fulfill()
    }
    
    pageControl.currentPage = value
    pageControl.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIPageControlDefaultsToEditingChangedEvent() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    var output: Int?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = pageControl |- Pipe {
      (input: Int) in
      output = input
      expectation.fulfill()
    }
    
    pageControl.currentPage = value
    pageControl.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIPageControlUpdatesOnInput() {
    let value = 5
    let pageControl = UIPageControl()
    pageControl.numberOfPages = value + 1
    let pipeline = Pipe() |- ControlPipe(pageControl)
    
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
  
  func testUISliderOutputsPageIndex() {
    let value = 0.7 as Float
    let control = UISlider()
    var output: Float?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(control, events: .EditingChanged) |- Pipe {
      (input: Float) in
      output = input
      expectation.fulfill()
    }
    
    control.value = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderDefaultsToEditingChangedEvent() {
    let value = 0.7 as Float
    let control = UISlider()
    var output: Float?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = control |- Pipe {
      (input: Float) in
      output = input
      expectation.fulfill()
    }
    
    control.value = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderUpdatesOnInput() {
    let value = 0.7 as Float
    let control = UISlider()
    let pipeline = Pipe() |- ControlPipe(control)
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.value, value)
  }
  
  func testUISliderUpdatesOnInputDirect() {
    let value = 0.7 as Float
    let control = UISlider()
    let pipeline = Pipe() |- control
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.value, value)
  }
  
  // MARK: UIStepper
  
  func testUIStepperOutputsPageIndex() {
    let value = 0.7 as Double
    let control = UIStepper()
    var output: Double?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(control, events: .EditingChanged) |- Pipe {
      (input: Double) in
      output = input
      expectation.fulfill()
    }
    
    control.value = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperDefaultsToEditingChangedEvent() {
    let value = 0.7 as Double
    let control = UIStepper()
    var output: Double?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = control |- Pipe {
      (input: Double) in
      output = input
      expectation.fulfill()
    }
    
    control.value = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperUpdatesOnInput() {
    let value = 0.7 as Double
    let control = UIStepper()
    let pipeline = Pipe() |- ControlPipe(control)
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.value, value)
  }
  
  func testUIStepperUpdatesOnInputDirect() {
    let value = 0.7 as Double
    let control = UIStepper()
    let pipeline = Pipe() |- control
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.value, value)
  }
  
  // MARK: UISwitch
  
  func testUISwitchOutputsPageIndex() {
    let value = true
    let control = UISwitch()
    var output: Bool?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(control, events: .EditingChanged) |- Pipe {
      (input: Bool) in
      output = input
      expectation.fulfill()
    }
    
    control.on = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchDefaultsToEditingChangedEvent() {
    let value = true
    let control = UISwitch()
    var output: Bool?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = control |- Pipe {
      (input: Bool) in
      output = input
      expectation.fulfill()
    }
    
    control.on = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchUpdatesOnInput() {
    let value = true
    let control = UISwitch()
    let pipeline = Pipe() |- ControlPipe(control)
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.on, value)
  }
  
  func testUISwitchUpdatesOnInputDirect() {
    let value = true
    let control = UISwitch()
    let pipeline = Pipe() |- control
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.on, value)
  }
  
  // MARK: UITextField
  
  func testUITextFieldOutputsPageIndex() {
    let value = "Pipeline!"
    let control = UITextField()
    var output: String?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(control, events: .EditingChanged) |- Pipe {
      (input: String) in
      output = input
      expectation.fulfill()
    }
    
    control.text = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldDefaultsToEditingChangedEvent() {
    let value = "Pipeline!"
    let control = UITextField()
    var output: String?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = control |- Pipe {
      (input: String) in
      output = input
      expectation.fulfill()
    }
    
    control.text = value
    control.sendActionsForControlEvents(.EditingChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldWithNilTextOutputsAnEmptyString() {
    let control = UITextField()
    control.text = nil
    XCTAssertEqual(control.controlValue(), "")
  }
  
  func testUITextFieldUpdatesOnInput() {
    let value = "Pipeline!"
    let control = UITextField()
    let pipeline = Pipe() |- ControlPipe(control)
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.text, value)
  }
  
  func testUITextFieldUpdatesOnInputDirect() {
    let value = "Pipeline!"
    let control = UITextField()
    let pipeline = Pipe() |- control
    
    pipeline.insert(value)
    
    XCTAssertEqual(control.text, value)
  }
}
