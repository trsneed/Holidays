//
//  CountryModelTests.swift
//  Holidays
//
//  Created by Tim Sneed on 8/29/15.
//  Copyright (c) 2015 Sneed. All rights reserved.
//

import UIKit
import XCTest
import SwiftyJSON
import Holidays
class CountryModelTests: XCTestCase {
	var country:Country!
	override func setUp() {
		super.setUp()
		let jsonString = "{\"fullName\":\"Angola\",\"countryCode\":\"ago\",\"fromDate\":{\"day\":1,\"month\":1,\"year\":2014},\"toDate\":{\"day\":31,\"month\":12,\"year\":32767}}"
		let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		let json = JSON(data: dataFromString!)
		country = Country(jsonDict: json)
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testHolidayHydrates(){
		XCTAssertEqual("ago", country.countryCode)
		XCTAssertEqual("Angola", country.name)
	}
}
