//
//  HelperTests.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import XCTest
import Holidays
class HelperTests: XCTestCase {
	
	func testDateFromValues(){
		let expectedDate = NSDate(timeIntervalSince1970: 1440738000)
		let resultDate = Helpers.dateFromValues(year: 2015, month: 8, day: 28)
		
		XCTAssertEqual(expectedDate, resultDate, "dates don't match")
	}
	
}
