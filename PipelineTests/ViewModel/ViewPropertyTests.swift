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
    let prop = ViewProperty(value: value, view: view) { (value, view, isValid) in
      value |- view
      view |- value
    }
    
    let expectation = expectationWithDescription("Process event on main loop")
    prop.viewPipe |- { (value) in
      expectation.fulfill()
    }
    
    prop.valuePipe.insert("something")
    
    waitForExpectationsWithTimeout(1.0, handler: nil)
    XCTAssertEqual(view.text, "something")
  }
}
