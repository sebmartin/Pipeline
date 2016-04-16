//
//  ValidatorTests.swift
//  Pipeline
//
//  Created by Seb Martin on 2016-04-12.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import XCTest
import Pipeline

class ValidatorTests: XCTestCase {
  func testValidatorOutputsTheValueAndTrueWhenValid() {
    var valueOutput = "initial-value"
    var isValidOutput = false

    let validator = Validator {
      $0 == "VALID"
    }
    
    let valuePipe = validator |- {
      return valueOutput = $0
    }
    
    validator.isValid |- Pipe {
      isValidOutput = $0
    }
    
    valuePipe.insert("INVALID")
    valuePipe.insert("VALID")
    
    XCTAssertEqual(valueOutput, "VALID")
    XCTAssertEqual(isValidOutput, true)
  }
  
  func testValidatorDoesNotOutputTheValueAndIsFalseWhenInvalid() {
    let validator = Validator {
      $0 == "VALID"
    }
    
    var valueOutput = "initial-value"
    let valuePipe = validator |- {
      return valueOutput = $0
    }
    
    var isValidOutput = false
    validator.isValid |- Pipe {
      isValidOutput = $0
    }
    
    valuePipe.insert("VALID")
    valuePipe.insert("INVALID")
    
    XCTAssertEqual(valueOutput, "VALID") // last valid value
    XCTAssertEqual(isValidOutput, false)
  }
}
