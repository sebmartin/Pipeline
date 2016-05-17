//
//  ViewPropertyTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-04-07.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class ViewPropertyTests: XCTestCase {
  // MARK: Initializers
  
  func testInitializeWithValuePipeViewPipeCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 }
    )
  }
  
  func testInitializeWithValuePipeViewPipeAndValidatorCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 },
      validator: Validator { (input) in return true }
    )
  }
  
  func testInitializeWithValuePipeViewPipeAndValidatorLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 },
      validator: { (input) in return true }
    )
  }
  
  func testInitializeWithValuePipeViewLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: { Int($0) ?? 0 }
    )
  }
  
  func testInitializeWithValuePipeViewLambdaAndValidatorCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: Validator { (input) in return true }
    )
  }
  
  func testInitializeWithValuePipeViewLambdaAndValidatorLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: Pipe { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: { (input) in return true }
    )
  }
  
  func testInitializeWithValueLambdaViewPipeCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 }
    )
  }
  
  func testInitializeWithValueLambdaViewPipeAndValidatorCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 },
      validator: Validator { (input) in return true }
    )
  }
  
  func testInitializeWithValueLambdaViewPipeAndValidatorLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: Pipe { Int($0) ?? 0 },
      validator: { (input) in return true }
    )
  }
  
  func testInitializeWithValueLambdaViewLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 }
    )
  }
  
  func testInitializeWithValueLambdaViewLambdaAndValidatorCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: Validator { (input) in return true }
    )
  }
  
  func testInitializeWithValueLambdaViewLambdaAndValidatorLambdaCompiles() {
    let _ = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: { (input) in return true }
    )
  }
  
  func testInitializeWithMatchingValueAndViewTypesCompiles() {
    let _ = ViewProperty(
      value: "initial",
      view: UITextField()
    )
  }
  
  func testInitializeWithMatchingValueAndViewTypesWithValidatorCompiles() {
    let _ = ViewProperty(
      value: "initial",
      view: UITextField(),
      validator: Validator { (input) in return true }
    )
  }
  
  func testInitializeWithMatchingValueAndViewTypesWithValidatorLambdaCompiles() {
    let _ = ViewProperty(
      value: "initial",
      view: UITextField(),
      validator: { (input) in return true }
    )
  }
  
  // MARK: Inserts and updates
  
  func testViewInsertsValueUpdatesValueObservable() {
    var prop = ViewProperty(
      value: "initial", view: UITextField(),
      valueOut: { $0 },
      viewOut: { $0 }
    )
    
    prop.viewPipe.insert("updated")
    
    XCTAssertEqual(prop.value, "updated")
    XCTAssertTrue(prop.isValidPipe.value)
  }
  
  func testUpdatingValueUpdatesTheViewValue() {
    var prop = ViewProperty(
      value: "initial", view: UITextField(),
      valueOut: { $0 },
      viewOut: { $0 }
    )
    
    prop.value = "updated"
    
    XCTAssertEqual(prop.view.text, "updated")
  }
  
  func testViewInsertsWithDifferentViewAndValueTypesUpdatesTheValue() {
    let prop = ViewProperty(
      value: 1 as Int, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 }
    )
    
    prop.viewPipe.insert("2")
    
    XCTAssertEqual(prop.value, 2)
    XCTAssertTrue(prop.isValidPipe.value)
  }
  
  func testValueInsertsWithDifferentViewAndValueTypesUpdatesTheView() {
    var prop = ViewProperty(
      value: 1, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 }
    )
    
    prop.value = 2
    
    XCTAssertEqual(prop.view.text, "2")
    XCTAssertTrue(prop.isValidPipe.value)
  }
  
  func testViewEntersValidDataDataValueIsUpdated() {
    let prop = ViewProperty(
      value: 1, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: Validator { $0 > 0 }
    )
    
    prop.viewPipe.insert("2")
    
    XCTAssertEqual(prop.value, 2)
    XCTAssertTrue(prop.isValidPipe.value)
  }
  
  func testViewEntersInvalidDataDataValueIsNotUpdated() {
    let prop = ViewProperty(
      value: 1, view: UITextField(),
      valueOut: { "\($0)" },
      viewOut: { Int($0) ?? 0 },
      validator: Validator { $0 < 0 }
    )
    
    prop.viewPipe.insert("2")
    
    XCTAssertEqual(prop.value, 1)
    XCTAssertFalse(prop.isValidPipe.value)
  }
  
  func testInsertWithMatchingValueAndViewTypesIsUpdated() {
    let prop = ViewProperty(
      value: "initial",
      view: UITextField()
    )
    
    prop.viewPipe.insert("updated")
    
    XCTAssertEqual(prop.view.text, "updated")
    XCTAssertTrue(prop.isValidPipe.value)
  }
  
  func testInsertWithMatchingValueAndViewTypesWithInvalidDataIsNotUpdated() {
    let prop = ViewProperty(
      value: "initial",
      view: UITextField(),
      validator: { (input) in return false }
    )
    
    prop.viewPipe.insert("updated")
    
    XCTAssertEqual(prop.value, "initial")
    XCTAssertFalse(prop.isValidPipe.value)
  }
}
