//
//  ViewFieldTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-04-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class ViewFieldTests: XCTestCase {
  func testFieldPropertyWithCompatibleTypesHasDefaultSetupFunction() {
    let value = "text"
    let view = UITextField()
    var prop = ViewProperty(value: value, view: view)
    
    prop.value = "something"
    
    XCTAssertEqual(view.text, "something")
  }
  
  func testFieldPropertyWithIncompatibleTypesCanBeUsedWithSetupFunction() {
    let value = 1
    let view = UITextField()
    var prop = ViewProperty(value: value, view: view)
    { (value, view, isValid) in
      value |- { "\($0)" } |- view
      view |- { Int($0) ?? 0 } |- value
    }
    
    prop.value = 123
    
    XCTAssertEqual(view.text, "123")
  }
  
  func testChangingControlValueUpdatesTheModelValue() {
    let value = "text"
    let view = UITextField()
    let prop = ViewProperty(value: value, view: view)
    
    let expectation = expectationWithDescription("Process event on main loop")
    prop.viewPipe.connect(Pipe<String, Void>{ (intput) in
      expectation.fulfill()
    })
    
    view.text = "something"
    view.sendActionsForControlEvents(.ValueChanged)

    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(prop.value, "something")
  }
  
  func testControlIsInitializedWithCurrentValue() {
    let value = "text"
    let view = UITextField()
    let prop = ViewProperty(value: value, view: view)
    
    XCTAssertEqual(view.text, "text")
    XCTAssertEqual(prop.value, "text")
  }
}
