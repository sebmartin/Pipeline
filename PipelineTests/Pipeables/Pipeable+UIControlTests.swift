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
    datePicker.sendActionsForControlEvents(.ValueChanged)
    
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
    let pipeline = ControlPipe(pageControl, events: .ValueChanged) |- Pipe {
      (input: Int) in
      output = input
      expectation.fulfill()
    }
    
    pageControl.currentPage = value
    pageControl.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIPageControlDefaultsToValueChangedEvent() {
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
    pageControl.sendActionsForControlEvents(.ValueChanged)
    
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
    let slider = UISlider()
    var output: Float?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(slider, events: .ValueChanged) |- Pipe {
      (input: Float) in
      output = input
      expectation.fulfill()
    }
    
    slider.value = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderDefaultsToValueChangedEvent() {
    let value = 0.7 as Float
    let slider = UISlider()
    var output: Float?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = slider |- Pipe {
      (input: Float) in
      output = input
      expectation.fulfill()
    }
    
    slider.value = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISliderUpdatesOnInput() {
    let value = 0.7 as Float
    let slider = UISlider()
    let pipeline = Pipe() |- ControlPipe(slider)
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.value, value)
  }
  
  func testUISliderUpdatesOnInputDirect() {
    let value = 0.7 as Float
    let slider = UISlider()
    let pipeline = Pipe() |- slider
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.value, value)
  }
  
  // MARK: UIStepper
  
  func testUIStepperOutputsPageIndex() {
    let value = 0.7 as Double
    let slider = UIStepper()
    var output: Double?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(slider, events: .ValueChanged) |- Pipe {
      (input: Double) in
      output = input
      expectation.fulfill()
    }
    
    slider.value = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperDefaultsToValueChangedEvent() {
    let value = 0.7 as Double
    let slider = UIStepper()
    var output: Double?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = slider |- Pipe {
      (input: Double) in
      output = input
      expectation.fulfill()
    }
    
    slider.value = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUIStepperUpdatesOnInput() {
    let value = 0.7 as Double
    let slider = UIStepper()
    let pipeline = Pipe() |- ControlPipe(slider)
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.value, value)
  }
  
  func testUIStepperUpdatesOnInputDirect() {
    let value = 0.7 as Double
    let slider = UIStepper()
    let pipeline = Pipe() |- slider
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.value, value)
  }
  
  // MARK: UISwitch
  
  func testUISwitchOutputsPageIndex() {
    let value = true
    let slider = UISwitch()
    var output: Bool?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(slider, events: .ValueChanged) |- Pipe {
      (input: Bool) in
      output = input
      expectation.fulfill()
    }
    
    slider.on = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchDefaultsToValueChangedEvent() {
    let value = true
    let slider = UISwitch()
    var output: Bool?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = slider |- Pipe {
      (input: Bool) in
      output = input
      expectation.fulfill()
    }
    
    slider.on = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUISwitchUpdatesOnInput() {
    let value = true
    let slider = UISwitch()
    let pipeline = Pipe() |- ControlPipe(slider)
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.on, value)
  }
  
  func testUISwitchUpdatesOnInputDirect() {
    let value = true
    let slider = UISwitch()
    let pipeline = Pipe() |- slider
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.on, value)
  }
  
  // MARK: UITextField
  
  func testUITextFieldOutputsPageIndex() {
    let value = "Pipeline!"
    let slider = UITextField()
    var output: String?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = ControlPipe(slider, events: .ValueChanged) |- Pipe {
      (input: String) in
      output = input
      expectation.fulfill()
    }
    
    slider.text = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldDefaultsToValueChangedEvent() {
    let value = "Pipeline!"
    let slider = UITextField()
    var output: String?
    let expectation = expectationWithDescription("Process event on main loop")
    let pipeline = slider |- Pipe {
      (input: String) in
      output = input
      expectation.fulfill()
    }
    
    slider.text = value
    slider.sendActionsForControlEvents(.ValueChanged)
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(output, value)
    XCTAssertNotNil(pipeline) // To prevent premature dealloc
  }
  
  func testUITextFieldWithNilTextOutputsAnEmptyString() {
    let slider = UITextField()
    slider.text = nil
    XCTAssertEqual(slider.controlValue(), "")
  }
  
  func testUITextFieldUpdatesOnInput() {
    let value = "Pipeline!"
    let slider = UITextField()
    let pipeline = Pipe() |- ControlPipe(slider)
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.text, value)
  }
  
  func testUITextFieldUpdatesOnInputDirect() {
    let value = "Pipeline!"
    let slider = UITextField()
    let pipeline = Pipe() |- slider
    
    pipeline.insert(value)
    
    XCTAssertEqual(slider.text, value)
  }
}
