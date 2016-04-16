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
    let validator = Validator {
      $0 == "VALID"
    }
    
    var valueOutput = "initial-value"
    let valuePipe = validator |- {
      return valueOutput = $0
    }
    
    var isValidOutput = false
    validator.isValid.connect(Pipe {
      isValidOutput = $0
    })
    
    valuePipe.insert("VALID")
    
    XCTAssertEqual(valueOutput, "VALID")
    XCTAssertEqual(isValidOutput, true)
  }
}
